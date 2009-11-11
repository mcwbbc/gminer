class AnnotationClosure < ActiveRecord::Base

  belongs_to :annotation
  belongs_to :ontology_term

end
