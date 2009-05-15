class Annotation
  include Utilities
  extend Utilities::ClassMethods
  include DataMapper::Resource

  property :ontology_term_id, String, :length => 255, :key => true
  property :geo_accession, String, :length => 25, :key => true
  property :field, String, :length => 25, :key => true
  property :ncbo_id, String, :length => 100, :index => true
  property :description, String, :length => 255
  property :from, Integer
  property :to, Integer
  property :verified, Boolean, :default => true

  belongs_to :ontology_term, :child_key => [:ontology_term_id]#, :counter_cache => true setup by rake persist:triggers
  belongs_to :ontology, :child_key => [:ncbo_id]#, :counter_cache => true setup by rake persist:triggers

  has n, :annotation_closures #, :include => :ontology_term, :order => "ontology_terms.name"

  class << self

    def count_by_ontology_array
      annotations = {}
      Constants::ONTOLOGIES.keys.each do |key|
        annotations[Constants::ONTOLOGIES[key][:name]] = Annotation.count(:ncbo_id => key)
      end
      array = annotations.sort_by { |k,v| v }
      array.reverse.map { |a| {:name => a[0], :amount => a[1]} }
    end

    def create_for(geo_accession, fields, description)
      fields.each do |field|
        a = Annotation.first(:geo_accession => geo_accession, :field => field[:name])
        if !a && !field[:value].blank?
          puts "BUILDING: #{geo_accession}:#{field[:name]}"
          cleaned = strip_newlines(field[:value])
          hash = NCBOService.result_hash(cleaned, Ontology.all.map {|x| x.ncbo_id}.join(","))
          process_ncbo_results(hash, geo_accession, field[:name], description)
        else
          puts "Skipping: #{geo_accession}:#{field[:name]} Exists: #{!!a}"
        end
      end
    end

    def process_closure(hash, geo_accession, field_name)
      hash.keys.each do |key|
        annotation = Annotation.first(:geo_accession => geo_accession, :field => field_name, :ontology_term_id => key)
        hash[key].each do |closure|
          ncbo_id, term_id = closure[:id].split("|")
          save_term(closure[:id], ncbo_id, closure[:name])
          annotation.annotation_closures.create(:ontology_term_id => closure[:id])
        end
      end
    end

    def process_mgrep(hash, geo_accession, field_name, description)
      if hash.keys.any?
        hash.keys.each do |key|
          ncbo_id, term_id = key.split("|")
          save_term(key, ncbo_id, hash[key][:name])
          a = Annotation.new(:geo_accession => geo_accession, :field => field_name, :ncbo_id => ncbo_id, :ontology_term_id => key, :from => hash[key][:from], :to => hash[key][:to], :description => description)
          a.save
        end
      else
        a = Annotation.new(:geo_accession => geo_accession, :field => field_name, :ncbo_id => "none", :ontology_term_id => "none", :from => "0", :to => "0")
        a.save
      end
    end

    def save_term(key, ncbo_id, term_name)
      ot = OntologyTerm.first(:term_id => key)
      if !ot
        ot = OntologyTerm.new(:term_id => key, :ncbo_id => ncbo_id, :name => term_name)
        ot.save
      end
    end

    def process_ncbo_results(hash, geo_accession, field_name, description)
      Annotation.transaction do
        process_mgrep(hash["MGREP"], geo_accession, field_name, description)
        process_closure(hash["ISA_CLOSURE"], geo_accession, field_name)
      end
    end

    def page(conditions, page=1, size=Constants::PER_PAGE)
      paginate(:order =>[DataMapper::Query::Direction.new(OntologyTerm.properties[:name], :asc)],
               :links => [:ontology_term, :ontology],
               :conditions => conditions,
               :page => page,
               :per_page => size
               )
    end

    def build_cloud(term_array)
      anatomy_terms = OntologyTerm.cloud(:ontology => "Mouse adult gross anatomy").sort_by { |term| term.name.downcase }
      rat_strain_terms = OntologyTerm.cloud(:ontology => "Rat Strain Ontology").sort_by { |term| term.name.downcase }
      @annotation_hash = Annotation.find_by_sql("SELECT * FROM annotations GROUP BY geo_accession ORDER BY geo_accession").inject({}) { |h, a| h[a.geo_accession] = a.description; h }

      if !term_array.blank?
        term_array.each do |term|
          annotations = Annotation.find_by_sql("SELECT * FROM annotations WHERE ontology_term_id = '#{term}' GROUP BY geo_accession ORDER BY geo_accession")
          hash = annotations.inject({}) { |h, a| h[a.geo_accession] = a.description; h }
          intersection = @annotation_hash.keys & hash.keys
          combine = @annotation_hash.dup.update(hash)
          @annotation_hash = {}
          intersection.each {|k| @annotation_hash[k] = combine[k] }
        end

        anatomy_term_ids = anatomy_terms.map { |term| term.term_id }
        rat_strain_term_ids = rat_strain_terms.map { |term| term.term_id }
        term_ids = []
        @annotation_hash.keys.each do |id|
          item = Annotation.load_item(id)
          item.annotations.each do |annotation|
            term_ids << annotation.ontology_term_id
          end
        end

        term_ids.uniq!
        at = anatomy_term_ids & term_ids
        rs = rat_strain_term_ids & term_ids
        @anatomy_terms = anatomy_terms.inject([]) { |a, term| a << term if at.include?(term.term_id); a  }
        @rat_strain_terms = rat_strain_terms.inject([]) { |a, term| a << term if rs.include?(term.term_id); a  }
      else
        @anatomy_terms = anatomy_terms
        @rat_strain_terms = rat_strain_terms
      end

      [@annotation_hash, @anatomy_terms.uniq, @rat_strain_terms.uniq]
    end

  end

  def toggle
    if self.verified?
      self.verified = false
    else
      self.verified = true
    end
    self.save
  end

end
