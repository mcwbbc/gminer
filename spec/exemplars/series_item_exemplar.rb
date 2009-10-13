class SeriesItem < ActiveRecord::Base
  generator_for :geo_accession => 'GSE8700'
  generator_for :pubmed_id => '12345'
  generator_for :title => 'Series Title'
  generator_for :overall_design => 'rat strain series'
  generator_for :summary => 'summary of series item'

#  generator_for (:platform_id) {Platform.generate.id}
end

