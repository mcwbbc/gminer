class Ontology
  include Utilities
  extend Utilities::ClassMethods
  include DataMapper::Resource
  
  property :ncbo_id, String, :length => 100, :key => true
  property :name, String, :length => 255
  property :version, String, :length => 25

  has n, :ontology_terms, :child_key => [:ncbo_id], :order => [:annotations_count.desc, :name]
  has n, :annotations, :child_key => [:ncbo_id]

  validates_present :name
  validates_is_unique :name

  class << self
    def page(conditions, page=1, size=Constants::PER_PAGE)
      paginate(:order => [:name],
               :conditions => conditions,
               :page => page,
               :per_page => size
               )
    end
  end

end
