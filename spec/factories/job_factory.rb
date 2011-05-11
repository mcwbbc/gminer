# The same, but using a string instead of class constant
Factory.define :job, :class => Job do |j|
  j.worker_key nil
  j.geo_accession 'GPL1355'
  j.field_name 'description'
  j.ontology_id 1
end
