class Dataset < ActiveRecord::Base
  generator_for :geo_accession => 'GDS8700'
  generator_for :reference_series => 'GSE8700'
  generator_for :title => 'rat strain dataset'
  generator_for :description => 'rat strain description'
  generator_for :organism => 'rat'
  generator_for :pubmed_id => '1234'

  generator_for (:platform_id) {Platform.generate.id}
end
