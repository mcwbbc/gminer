# The same, but using a string instead of class constant
Factory.define :ontology_term, :class => OntologyTerm do |o|

  o.sequence(:term_id) {|ncbo_id| "#{ncbo_id}|a" }
  o.sequence(:ncbo_id) {|id| "#{id}".to_i }
  o.sequence(:name) {|letter| "#{letter}" }

end
