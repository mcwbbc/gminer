module AnnotationsHelper

  def ontology_search_dropdown(current)
    select_tag(:ddown, options_from_collection_for_select(Ontology.which_have_annotations, :ncbo_id, :name, current))
  end

  def annotation_status_dropdown(current)
    select_tag(:status, options_for_select(["Unaudited", "Valid", "Invalid", "All"], current))
  end
end
