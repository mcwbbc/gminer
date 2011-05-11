class ResourceIndexAnnotationsController < ApplicationController

  before_filter :admin_required

  # GET /resource_index_annotations
  def index
    @q = params[:query]
    page = (params[:page].to_i > 0) ? params[:page] : 1

    q_front = "#{@q}%"

    cstring = "geo_accession LIKE ?"
    conditions = [cstring, q_front]

    find_resource_index_annotations(conditions, page)
    #if we have a page > the last one, redo the query turning the page into the last one
    find_resource_index_annotations(conditions, @resource_index_annotations.total_pages) if params[:page].to_i > @resource_index_annotations.total_pages

    respond_to do |format|
      format.html { }
      format.js {
        render(:partial => "resource_index_annotations_list.html.haml")
      }
    end
  end

  # GET /resource_index_annotations/GDS1002
  def show
    @geo_item = Dataset.load_item(params[:id])
    raise ActiveRecord::RecordNotFound if !@geo_item

    @geo_item_annotations, @common_annotations = Annotation.comparison_annotations_for(@geo_item.geo_accession)
    @resource_index_annotations = ResourceIndexAnnotation.exclusive_for(@geo_item.geo_accession)

    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "That GEO item does not exist."
      redirect_to(resource_index_annotations_url)
  end

  protected

  def find_resource_index_annotations(conditions, page)
    @resource_index_annotations = ResourceIndexAnnotation.page(conditions, page, Constants::PER_PAGE)
  end

end
