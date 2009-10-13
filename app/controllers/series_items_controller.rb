class SeriesItemsController < ApplicationController

  def index
    @q = params[:query]
    page = (params[:page].to_i > 0) ? params[:page] : 1

    q_front = "#{@q}%"
    q_both = "%#{@q}%"

    cstring = "geo_accession LIKE ? OR summary LIKE ?"
    conditions = [cstring, q_front, q_both]

    find_series_items(conditions, page)
    #if we have a page > the last one, redo the query turning the page into the last one
    find_series_items(conditions, @series_items.total_pages) if params[:page].to_i > @series_items.total_pages

    respond_to do |format|
      format.html {
          @annotation_count_array = SeriesItem.annotation_count_array
        }
      format.js  {
          render(:partial => "series_items_list")
        }
    end
  end

  def show
    @series_item = SeriesItem.first(:conditions => {:geo_accession => params[:id]})
    raise ActiveRecord::RecordNotFound if !@series_item
    @prev, @next = @series_item.prev_next
    respond_to do |format|
      format.html
    end
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "That series does not exist."
      redirect_to(series_items_url)
  end

  protected
    def find_series_items(conditions, page)
      @series_items = SeriesItem.page(conditions, page, Constants::PER_PAGE)
    end

end
