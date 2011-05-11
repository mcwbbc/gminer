# The same, but using a string instead of class constant
Factory.define :annotation, :class => Annotation do |a|
  a.geo_accession 'GSE8700'
  a.field_name 'Annotation Title'
  a.description  'rat strain description'
  a.predicate  'text'
  a.from  1
  a.to  10
  a.created_by_id  1
  a.curated_by_id  1
end
