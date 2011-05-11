class Annotation < ActiveRecord::Base
  include Utilities
  extend Utilities::ClassMethods

  attr_accessor :ncbo_term_id, :ncbo_term_name

  validates_uniqueness_of :ncbo_id, :scope => [:ontology_term_id, :geo_accession, :field_name]

  belongs_to :ontology_term, :counter_cache => true
  belongs_to :ontology

  belongs_to :curator, :class_name => 'User', :inverse_of => :curated_annotations, :foreign_key => :curated_by_id
  belongs_to :creator, :class_name => 'User', :inverse_of => :created_annotations, :foreign_key => :created_by_id

  has_many :annotation_closures, :dependent => :delete_all #, :include => :ontology_term, :order => "ontology_terms.name"

  scope :mouse_anatomy, :conditions => { :ncbo_id => "1000"}
  scope :rat_strain, :conditions => { :ncbo_id => "1150"}
  scope :manual, :conditions => ['created_by_id > ?', 0]

  scope :daily, where('annotations.updated_at > ?', 1.day.ago)
  scope :verified, where(:verified => true)
  scope :audited, where(:status => 'audited')

  class << self

    def comparison_annotations_for(geo_accession)
      identifiers = ResourceIndexAnnotation.select(:identifier).where(:geo_accession => geo_accession).map {|a| a.identifier.gsub('summary', 'description')}.uniq
      exclusive = Annotation.where(:geo_accession => geo_accession).where("identifier NOT IN (#{identifiers.to_in_query_string})").order('identifier')
      common = Annotation.where(:geo_accession => geo_accession).where("identifier IN (#{identifiers.to_in_query_string})").order('identifier')

      [convert_to_field_ontology_hash(exclusive), convert_to_field_ontology_hash(common)]
    end

    def top(group_by='curated_by_id', daily=false)
      query = select('email, count(annotations.id) AS count').audited.joins("INNER JOIN users ON users.id = annotations.#{group_by}").where('admin = ?', true).order('count DESC').group(group_by).limit(5)

      if daily
        query.daily
      else
        query
      end
    end

    def field_names_for_ontology(ncbo_id)
      if ncbo_id == "all"
        find(:all, :select => 'field_name', :group => 'field_name').map(&:field_name)
      else
        find(:all, :select => 'field_name, ncbo_id', :group => 'field_name', :conditions => {:ncbo_id => ncbo_id}).map(&:field_name)
      end
    end

    def for_item(item, current_user_id)
      Annotation.new(:created_by_id => current_user_id, :curated_by_id => current_user_id, :status => 'audited', :verified => true, :description => item.descriptive_text, :geo_accession => item.geo_accession)
    end

    def count_by_ontology_array
      annotations = {}
      Constants::ONTOLOGIES.keys.each do |key|
        annotations[Constants::ONTOLOGIES[key][:name]] = Annotation.count(:conditions => {:ncbo_id => key})
      end
      array = annotations.sort_by { |k,v| v }
      array.reverse.map { |a| {:amount => a[1], :name => a[0]} }
    end

    def page(conditions, page=1, size=Constants::PER_PAGE)
      paginate(:order => "ontology_terms.name, annotations.geo_accession",
               :include => [:ontology_term, :ontology],
               :conditions => conditions,
               :page => page,
               :per_page => size
               )
    end

    def find_for_curation(conditions, user_id)
      RedisConnection.db.sadd('curators', user_id)
      RedisConnection.db.del("curator-#{user_id}")
      curator_ids = RedisConnection.db.smembers('curators')
      curator_keys = curator_ids.map { |id| "curator-#{id}" }
      active_annotation_ids = RedisConnection.db.sunion(*curator_keys)
      annotations = Annotation.where(conditions).where("annotations.id NOT IN (#{active_annotation_ids.to_in_query_string})").limit(15).order('annotations.term_name')
      annotations.each do |annotation|
        RedisConnection.db.sadd("curator-#{user_id}", annotation.id)
      end
      RedisConnection.db.expire("curator-#{user_id}", 300)
      annotations
    end

    def geo_items(term_array, page)
      query_array = term_array.inject([]) do |a, term|
        a << "(SELECT DISTINCT geo_accession, description FROM annotations INNER JOIN ontology_terms ON ontology_terms.id = annotations.ontology_term_id AND annotations.verified = 1 AND ontology_terms.term_id = '#{term}')"
        a
      end
      query_string = query_array.join(" UNION ALL ")
      total_count_sql = "SELECT COUNT(*) FROM (SELECT * FROM (#{query_string}) AS tmp GROUP BY tmp.geo_accession HAVING COUNT(*) = #{term_array.size}) AS countme"
      total_count = Annotation.count_by_sql(total_count_sql)
      sql = "SELECT * FROM (#{query_string}) AS tmp GROUP BY tmp.geo_accession HAVING COUNT(*) = #{term_array.size}"
      res = Annotation.find_by_sql(sql)
      mapped = res.map(&:geo_accession)
      result = res.paginate(:page => page, :per_page => 10)
      [total_count, result, mapped]
    end

    def build_cloud(term_array, page)
      if term_array.blank?
        total_count = 0
        @annotations = []
        @anatomy_terms = OntologyTerm.cloud_term_ids(:ontology_ncbo_id => "1000")
        @rat_strain_terms = OntologyTerm.cloud_term_ids(:ontology_ncbo_id => "1150")
      else
        total_count, @annotations, geo_record_ids = Annotation.geo_items(term_array, page)
        @anatomy_terms = OntologyTerm.cloud_term_ids(:ontology_ncbo_id => "1000", :geo_term_array => geo_record_ids).inject([]) {|a, term| a << term if !term_array.include?(term.term_id); a}
        @rat_strain_terms = OntologyTerm.cloud_term_ids(:ontology_ncbo_id => "1150", :geo_term_array => geo_record_ids).inject([]) {|a, term| a << term if !term_array.include?(term.term_id); a}
      end

      [total_count, @annotations, @anatomy_terms, @rat_strain_terms]
    end
  end #of self

  def audited?
    self.status == 'audited'
  end

  def term_text
    field_value[(self.from-1)..(self.to-1)]
  end

  def full_text_highlighted
    text = field_value
    term = "<strong class='highlight'>#{text[(self.from-1)..(self.to-1)]}</strong>"
    if self.from != 1
      term = text[0..(self.from-2)] << term
    end

    if self.to != text.size
      term = term << text[self.to..text.size]
    end
    term.html_safe
  end

  def in_context
    extended = 50
    start = 0
    finish = 0
    text = field_value
    prefix = ""
    suffix = ""
    term = "<strong class='highlight'>#{text[(self.from-1)..(self.to-1)]}</strong>".html_safe
    start = (self.from-extended > 0) ? self.from-extended : 0

    if self.from-1 > 0
      if self.from-extended > 0
        prefix = "..."+text[start..(self.from-2)]
      else
        prefix = text[start..(self.from-2)]
      end
    end

    if self.to+extended > text.size
      if self.to+1 <= text.size
        suffix = text[(self.to)..text.size]
      end
    else
      finish = self.to+extended
      suffix = text[(self.to)..finish]+"..."
    end
    (prefix+term+suffix).html_safe
  end

  def field_value
    m = Annotation.load_item(self.geo_accession)
    m.send(field_name)
  end

  def set_status(user_id)
    if self.status == 'unaudited'
      self.status = 'audited'
      self.curated_by_id = user_id
    end

    if self.verified?
      self.verified = false
    else
      self.verified = true
    end
    self.save
  end

  def resource_id
    ontology_term.term_id.gsub('|','/')
  end

  def auto_curate
    if (!!(ontology_term.name =~ /^.+?\/.+?$/) || !!(ontology_term.name =~ /^.+?:.+?$/)) # does it have a / or :
      if field_value.match(ontology_term.name) # can it be found directly in the text
        update_attributes(:verified => true, :status => 'audited')
      else
        update_attributes(:verified => false, :status => 'audited')
      end
    elsif check_ratmine # does it have a parent that has also been annotated
      update_attributes(:verified => false, :status => 'audited')
    else
      update_attributes(:verified => true, :status => 'audited')
    end
  end

  def check_ratmine
    parents = RatmineService.parent_array(ontology_term.term_id.split('|').last)
    (parents & sibling_annotation_term_ids).any?
  end

  def sibling_annotation_term_ids
    term_ids = Annotation.select('ontology_terms.term_id').where("annotations.id != #{self.id}").where(:geo_accession => geo_accession).where(:field_name => field_name).where(:ncbo_id => ncbo_id).joins(:ontology_term).map {|annotation| annotation.term_id.split('|').last }
  end
end