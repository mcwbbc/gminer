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
      format.js  {
          render(:partial => "datasets_list")
        }
    end
  end

  # GET /datasets/1
  def show
    @dataset = Dataset.first(:conditions => {:geo_accession => params[:id]})
    raise ActiveRecord::RecordNotFound if !@dataset
    @prev, @next = @dataset.prev_next
    respond_to do |format|
      format.html # show.html.erb
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
