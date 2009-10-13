class Ontology < ActiveRecord::Base
  generator_for :ncbo_id => "1000"
  generator_for :current_ncbo_id => "13578"
  generator_for :name => "mouse anatomy"
  generator_for :version => "1"
  generator_for :stopwords => "a,the,an"
end
