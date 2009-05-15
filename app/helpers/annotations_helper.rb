module Merb
  module AnnotationsHelper

    def ontology_search_dropdown(current)
      select(:ddown, :label => "Ontology: ", :id => "ddown", :value_method=> :name, :text_method => :name, :collection => Ontology.all(:order => [:name]), :selected => current)
    end

  end
end # Merb


