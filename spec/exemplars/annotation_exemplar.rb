class Annotation < ActiveRecord::Base
  generator_for :geo_accession => 'GSE8700'
  generator_for :field => 'title'
  generator_for :description => 'rat strain description'
  generator_for :from => 1
  generator_for :to => 10
  generator_for :user_id => 1
end
