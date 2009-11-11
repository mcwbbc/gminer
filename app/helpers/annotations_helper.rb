module AnnotationsHelper

  def ontology_search_dropdown(current)
    select_tag(:ddown, options_from_collection_for_select(Ontology.which_have_annotations, :ncbo_id, :name, current))
  end

  def annotation_status_dropdown(current)
    select_tag(:status, options_for_select(["Unaudited", "Valid", "Invalid", "All"], current))
  end

  def annotation_geotype_dropdown(current)
    select_tag(:geotype, options_for_select(["All", "Platform", "Dataset", "Series", "Sample"], current))
  end

  def cloud_sample_count(hash_size, sample_count)
    if sample_count < 0
      return
    else
      text = "Has annotations that reference #{sample_count} GEO accession IDs."
      if sample_count > hash_size
        text << " Limited to the first 100 records."
      end
      text
    end
  end

end
