class PagesController < ApplicationController  

  def home
    @ontologies = ["Rat Strain Ontology", "Mouse adult gross anatomy"]
    @terms = [{:title => "All Terms", :values => OntologyTerm.cloud(:limit => 20).sort_by { |term| term.name.downcase }}]
    @ontologies.each do |ontology|
      @terms << {:title => ontology, :values => OntologyTerm.cloud(:limit => 20, :ontology => ontology).sort_by { |term| term.name.downcase } }
    end
  end
  
  def css_test
  end
  
  def kaboom
    User.first.kaboom!
  end

  def upgrade
  end
  
end
