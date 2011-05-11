class DatasetsController < ApplicationController
  # GET /datasets
  def index
    @q = params[:query]
    page = (params[:page].to_i > 0) ? params[:page] : 1

    q_front = "#{@q}%"
    q_both = "%#{@q}%"

    cstring = "geo_accession LIKE ? OR title LIKE ?"
    conditions = [cstring, q_front, q_both]

    find_datasets(conditions, page)
    #if we have a page > the last one, redo the query turning the page into the last one
    find_datasets(conditions, @datasets.total_pages) if params[:page].to_i > @datasets.total_pages

    respond_to do |format|
      format.html {
        @annotation_count_array = Dataset.annotation_count_array
      }
      format.js {
        render(:partial => "datasets_list.html.haml")
      }
    end
  end

  # GET /datasets/1
  def show
    @dataset = Dataset.first(:conditions => {:geo_accession => params[:id]})
    raise ActiveRecord::RecordNotFound if !@dataset

    if admin?
      @new_annotation = Annotation.for_item(@dataset, current_user.id)
      @ontologies = Ontology.all(:order => :name)
      @top_tags = Tag.top_tags(@dataset.tag_list)
      @all_tags = Tag.all_tags(@dataset.tag_list).map(&:name)
      @prev, @next = @dataset.prev_next
      @geo_item_annotations, @common_annotations = Annotation.comparison_annotations_for(@dataset.geo_accession)
      @resource_index_annotations = ResourceIndexAnnotation.exclusive_for(@dataset.geo_accession)
    end

    respond_to do |format|
      format.html {
        @annotation_count_array = @dataset.count_by_ontology_array
      }
    end
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "That dataset does not exist."
      redirect_to(datasets_url)
  end

  protected
    def find_datasets(conditions, page)
      @datasets = Dataset.page(conditions, page, Constants::PER_PAGE)
    end

end
