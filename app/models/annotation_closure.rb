class AnnotationClosure
  include DataMapper::Resource
  
  property :id, Serial
  property :annotation_geo_accession, String, :length => 25, :index => :geo_accession_field_ontology_term_id
  property :annotation_field, String, :length => 25, :index => :geo_accession_field_ontology_term_id
  property :annotation_ontology_term_id, String, :length => 25, :index => :geo_accession_field_ontology_term_id
  property :ontology_term_id, String, :length => 100, :index => true

  belongs_to :annotation, :child_key => [:annotation_ontology_term_id, :annotation_geo_accession, :annotation_field]
  belongs_to :ontology_term, :child_key => [:ontology_term_id]

end
