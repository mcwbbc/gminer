class Home < Application

  def index
    @ontologies = ["Rat Strain Ontology", "Mouse adult gross anatomy", "Medical Subject Headings, 2009_2008_08_06"]
    @terms = [{:title => "All Terms", :values => OntologyTerm.cloud(:limit => 20).sort_by { |term| term.name.downcase }}]
    @ontologies.each do |ontology|
      @terms << {:title => ontology, :values => OntologyTerm.cloud(:limit => 20, :ontology => ontology).sort_by { |term| term.name.downcase } }
    end
    render
  end
  
end

