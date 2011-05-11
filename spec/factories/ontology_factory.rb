# The same, but using a string instead of class constant
Factory.define :ontology, :class => Ontology do |o|
  o.ncbo_id "1000"
  o.current_ncbo_id "13578"
  o.name "mouse anatomy"
  o.version "1"
  o.stopwords "a,the,an"
end
