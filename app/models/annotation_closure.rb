class AnnotationClosure < ActiveRecord::Base

  belongs_to :annotation
  belongs_to :ontology_term

  class << self
    def page(conditions, page=1, size=Constants::PER_PAGE)
        paginate(:order => "annotations.geo_accession",
               :include => [:annotation],
               :group => 'annotations.geo_accession',
               :conditions => conditions,
               :page => page,
               :per_page => size
               )
    end
  end #of self

end
