class OntologyTerm
  include DataMapper::Resource
  
  property :term_id, String, :length => 100, :key => true
  property :ncbo_id, String, :length => 100
  property :name, String, :length => 255
  property :annotations_count, Integer, :default => 0 

  belongs_to :ontology, :child_key => [:ncbo_id]
  has n, :annotations, :child_key => [:ontology_term_id]#, :order => :geo_accession, :dependent => :destroy

  has n, :annotation_closures, :child_key => [:ontology_term_id]#, :include => :annotation, :order => "annotations.geo_accession", :dependent => :destroy

  class << self
    def page(conditions, page=1, size=Constants::PER_PAGE)
      paginate(:order => [:name],
               :conditions => conditions,
               :page => page,
               :per_page => size
               )
    end

    def cloud(options = {})
      query = "SELECT ontology_terms.*"
      query << " FROM ontology_terms, ontologies"
      query << " WHERE ontology_terms.annotations_count > 0"
      query << " AND ontology_terms.ncbo_id = ontologies.ncbo_id AND ontologies.name = '#{options[:ontology]}'" if options[:ontology] != nil
      query << " GROUP BY ontology_terms.name"
      query << " ORDER BY ontology_terms.annotations_count DESC, ontology_terms.name"
      query << " LIMIT #{options[:limit]}" if options[:limit] != nil
      cloud = OntologyTerm.find_by_sql(query)
    end
  end

  def direct_geo_references
    annotations.inject([]) { |array, a| array << {:geo_accession => a.geo_accession, :description => a.description}; array }
  end

  def closure_geo_references
    annotation_closures.inject([]) { |array, ac| array << {:geo_accession => ac.annotation.geo_accession, :description => ac.annotation.description}; array }
  end

  def parent_closures
    sql = "SELECT ontology_terms.*"
    sql << " FROM annotations, annotation_closures, ontology_terms"
    sql << " WHERE annotations.ontology_term_id = '#{self.term_id}'"
    sql << " AND annotations.geo_accession = annotation_closures.annotation_geo_accession"
    sql << " AND annotations.field = annotation_closures.annotation_field"
    sql << " AND ontology_terms.term_id = annotation_closures.ontology_term_id"
    sql << " GROUP BY annotation_closures.ontology_term_id"
    sql << " ORDER BY ontology_terms.name"
    terms = OntologyTerm.find_by_sql(sql)
  end

  def child_closures
    acs = AnnotationClosure.all(:ontology_term_id => self.term_id, :order => [DataMapper::Query::Direction.new(OntologyTerm.properties[:name], :asc)], :links => [:ontology_term])
    terms = acs.inject([]) do |array, ac|
      array << ac.annotation.ontology_term
      array
    end
    terms.uniq
  end

  def link_item(key)
    case key
      when /^GSM/
        m = "samples"
      when /^GSE/
        m = "series_item"
      when /^GPL/
        m = "platforms"
      when /^GDS/
        m = "datasets"
    end
    "<a href='/#{m}/#{key}'>#{key}</a>"
  end

end
