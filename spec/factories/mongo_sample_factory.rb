# The same, but using a string instead of class constant
Factory.define :mongo_sample, :class => Mongo::Sample do |s|
  s.geo_accession 'GSM1234'
  s.title 'Sample Title'
  s.organism 'rat'
  s.sample_type 'sample_type'
  s.source_name 'source_name'
  s.characteristics 'characteristics'
  s.treatment_protocol 'treatment_protocol'
  s.extract_protocol 'extract_protocol'
  s.label 'label'
  s.label_protocol 'label_protocol'
  s.scan_protocol 'scan_protocol'
  s.hyp_protocol 'hyp_protocol'
  s.description 'description'
  s.data_processing 'data_processing'
  s.molecule 'molecule'
end
