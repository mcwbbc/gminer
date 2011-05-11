class OntologyTerm < ActiveRecord::Base

  belongs_to :ontology
  has_many :annotations, :dependent => :delete_all, :order => :geo_accession#, :dependent => :destroy
  has_many :annotation_closures, :dependent => :delete_all, :include => :annotation, :order => "annotations.geo_accession"#, :dependent => :destroy

  has_many :valid_annotations, :class_name => "Annotation", :conditions => {:verified => true}, :order => :geo_accession#, :dependent => :destroy
  has_many :valid_annotation_closures, :class_name => "AnnotationClosure", :conditions => ['annotations.verified = ?', true], :include => :annotation, :order => "annotations.geo_accession"#, :dependent => :destroy

#  has n, :results, :foreign_key => :ontology_term_id#, :order => :sample_geo_accession, :dependent => :destroy # they exist, but don't associate in case of lazy load

  class << self

    def for_samples(sample_array)
      joins = "INNER JOIN annotations ON ontology_terms.id = annotations.ontology_term_id"
      find(:all,
        :select => 'ontology_terms.name, ontology_terms.term_id, count(distinct(annotations.geo_accession)) as term_count',
        :joins => joins,
        :conditions => ["annotations.geo_accession IN (?) AND annotations.verified = 1", sample_array],
        :group => "ontology_terms.term_id",
        :order => 'term_count DESC, ontology_terms.name'
      )
    end

    def page(conditions, page=1, size=Constants::PER_PAGE)
      join = "INNER JOIN annotations ON ontology_terms.id = annotations.ontology_term_id AND annotations.verified = 1"
      paginate(:order => 'name',
               :conditions => conditions,
               :joins => join,
               :group => 'annotations.term_id',
               :page => page,
               :per_page => size
               )
    end

    def page_for_ontology(conditions, page=1, size=Constants::PER_PAGE)
      paginate(:order => "annotations_count DESC, name",
               :conditions => conditions,
               :page => page,
               :per_page => size
               )
    end

    def cloud_term_ids(options = {})
      order = options[:limit] ? 'annotations_count DESC' : 'name'
      join = "INNER JOIN annotations ON ontology_terms.id = annotations.ontology_term_id AND annotations.verified = 1"
      join << " AND ontology_terms.ncbo_id = '#{options[:ontology_ncbo_id]}'" if options[:ontology_ncbo_id]
      join << " AND annotations.geo_accession IN (#{options[:geo_term_array].to_in_query_string})" if options[:geo_term_array]
      find(:all, :select => 'ontology_terms.term_id, ontology_terms.name, count(DISTINCT geo_accession) AS annotations_count', :joins => join, :order => order, :group => 'ontology_terms.term_id', :limit => options[:limit])
    end
  end # of self

  def to_param
    self.term_id
  end

  def specific_term_id
    self.term_id.split("|").last
  end

  def valid_annotation_percentage
    if annotations_count > 0
      (valid_annotation_count.to_f/annotations_count.to_f)*100
    else
      0
    end
  end

  def audited_annotation_percentage
    if annotations_count > 0
      (audited_annotation_count.to_f/annotations_count.to_f)*100
    else
      0
    end
  end

  def valid_annotation_count
    Annotation.count(:conditions => {:ontology_term_id => self.id, :verified => true})
  end

  def audited_annotation_count
    Annotation.count(:conditions => {:ontology_term_id => self.id, :status => 'audited'})
  end

  def direct_geo_references
    valid_annotations.inject([]) { |array, a| array << {:geo_accession => a.geo_accession, :description => a.description}; array }.uniq
  end

  def closure_geo_references
    valid_annotation_closures.inject([]) { |array, ac| array << {:geo_accession => ac.annotation.geo_accession, :description => ac.annotation.description}; array }.uniq
  end

  def parent_closures
    sql = "SELECT DISTINCT ontology_terms.*"
    sql << " FROM annotations, annotation_closures, ontology_terms"
    sql << " WHERE annotations.ontology_term_id = #{self.id}"
    sql << " AND annotations.id = annotation_closures.annotation_id"
    sql << " AND ontology_terms.id = annotation_closures.ontology_term_id"
    sql << " ORDER BY ontology_terms.name"
    terms = OntologyTerm.find_by_sql(sql)
  end

  def child_closures
    acs = AnnotationClosure.all(:conditions => {:ontology_term_id => self.id}, :order => "ontology_terms.name", :include => [:ontology_term])
    terms = acs.inject([]) do |array, ac|
      array << ac.annotation.ontology_term
      array
    end
    terms.uniq
  end

  def geo_counts
    [["GPL", "Platform"], ["GDS", "Dataset"], ["GSE", "Series"], ["GSM", "Sample"]].inject([]) do |array, geo|
      count = annotations.count('geo_accession', :distinct => true, :conditions => ['geo_accession LIKE ? AND verified = ?', "#{geo[0]}%", true])
      array << [geo[1], count] if count > 0
      array
    end
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
    "<a href='/#{m}/#{key}'>#{key}</a>".html_safe
  end

end
