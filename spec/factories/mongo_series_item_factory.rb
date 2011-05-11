# The same, but using a string instead of class constant
Factory.define :mongo_series_item, :class => Mongo::SeriesItem do |s|
  s.geo_accession 'GSE8700'
  s.pubmed_id '12345'
  s.title 'Series Title'
  s.overall_design 'rat strain series'
  s.summary 'summary of series item'
end
