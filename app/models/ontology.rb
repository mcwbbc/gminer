class Ontology < ActiveRecord::Base
  include Utilities
  extend Utilities::ClassMethods

  has_many :ontology_terms, :order => "annotations_count DESC, name"
  has_many :annotations

  validates_presence_of :name
  validates_uniqueness_of :name

  class << self
    def page(conditions, page=1, size=Constants::PER_PAGE)
      paginate(:order => [:name],
               :conditions => conditions,
               :page => page,
               :per_page => size
               )
    end

    def which_have_annotations
      Ontology.all(:order => [:name]).select { |ontology| ontology if ontology.annotations.size > 0 }
    end

  end

  def update_data
    self.current_ncbo_id, self.name, self.version = NCBOService.current_ncbo_id(self.ncbo_id)
    save!
  end

end
