# The same, but using a string instead of class constant
Factory.define :mongo_annotation, :class => Mongo::Annotation do |a|
  a.geo_accession 'GSE8700'
  a.field_name 'Annotation Title'
  a.description  'rat strain description'
  a.from  1
  a.to  10
  a.curated_by_id  1
  a.created_by_id  1
end
