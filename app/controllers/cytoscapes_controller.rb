class CytoscapesController < ApplicationController

  def item_json
    geo_accession = params[:id]
    item = Dataset.load_item(geo_accession)
    render(:json => {'item_data' => item.cytoscape_data, 'valid_annotation_count' => item.resource_term_ids.size}.to_json)
  end

  def resource_term_ids
    geo_accession = params[:id]
    item = Dataset.load_item(geo_accession)
    render(:json => item.resource_term_ids.to_json)
  end

  def resource_count
    term_ids = params[:term_ids]
    count = NcboResourceService.resource_count(term_ids)
    render(:json => {'resource_count' => count}.to_json)
  end

  def resource_count_hash
    term_ids = params[:term_ids]
    hash = NcboResourceService.resource_count_hash(term_ids)
    render(:json => {'resource_count_hash' => hash}.to_json)
  end


end
