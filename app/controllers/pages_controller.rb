class PagesController < ApplicationController

  def home
    @ontology_ncbo_ids = ["1150", "1000"]
    @terms = [{:title => "All Terms", :values => OntologyTerm.cloud(:limit => 20).sort_by { |term| term.name.downcase }}]
    @ontology_ncbo_ids.each do |ontology_ncbo_id|
      @terms << {:title => Constants::ONTOLOGIES[ontology_ncbo_id][:name], :values => OntologyTerm.cloud(:limit => 20, :ontology_ncbo_id => ontology_ncbo_id).sort_by { |term| term.name.downcase } }
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
