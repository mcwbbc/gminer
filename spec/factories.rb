# SeriesItem factory
Factory.define :series_item do |s|
  s.geo_accession 'GSE8700'
  s.platform_geo_accession 'GPL1355'
  s.pubmed_id '12345'
  s.title 'Series Title'
  s.overall_design 'rat strain series'
  s.summary 'RS:1000'
end

# Sample factory
Factory.define :sample do |s|
  s.geo_accession 'GSM1234'
  s.series_geo_accession 'GSE8700'
  s.platform_geo_accession 'GPL1355'
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

# Platform factory
Factory.define :platform do |p|
  p.geo_accession 'GPL1355'
  p.organism 'rat'
  p.title 'Platform Title'
end

# OntologyTerm factory
Factory.define :ontology_term do |o|
  o.name 'Property or Attribute'
  o.ncbo_id '13578'
  o.term_id 'Properties_or_Attributes'
  o.annotations_count 0
end

# Ontology factory
Factory.define :ontology do |o|
  o.ncbo_id '13578'
  o.name 'Property or Attribute'
  o.version '1'
end

# Detection factory
Factory.define :detection do |d|
  d.sample_geo_accession 'GSM1234'
  d.id_ref '1234_at'
  d.abs_call 'P'
end

# Dataset factory
Factory.define :dataset do |d|
  d.geo_accession 'GSE8700'
  d.platform_geo_accession 'GPL1355'
  d.reference_series 'GSE8700'
  d.title 'rat strain dataset'
  d.description 'rat strain description'
  d.organism 'rat'
  d.pubmed_id '1234'
end

# Annotation factory
Factory.define :annotation do |a|
  a.geo_accession 'GSE8700'
  a.field 'title'
  a.ontology_term_id 'RS:1000'
  a.description 'rat strain description'
  a.from 1
  a.to 10
end

# Result factory
Factory.define :result do |a|
  a.sample_geo_accession 'GSM8700'
  a.id_ref 'id_ref'
  a.ontology_term_id 'RS:1000'
  a.pubmed_id '1234'
end
