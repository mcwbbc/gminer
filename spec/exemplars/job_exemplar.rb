class Job < ActiveRecord::Base
  generator_for :worker_key => nil
  generator_for :geo_accession => 'GPL1355'
  generator_for :field => "description"
  generator_for :ontology_id => 1
end
