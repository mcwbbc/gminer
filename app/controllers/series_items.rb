class SeriesItems < Application

  def index
    provides :js 
    @q = params[:query]
    page = (params[:page].to_i > 0) ? params[:page] : 1

    q_front = "#{@q}%"
    q_both = "%#{@q}%"

    cstring = "geo_accession LIKE ? OR summary LIKE ?"
    conditions = [cstring, q_front, q_both]

    find_series_items(conditions, page)
    #if we have a page > the last one, redo the query turning the page into the last one
    find_series_items(conditions, @series_items.total_pages) if params[:page].to_i > @series_items.total_pages

    case content_type 
      when :js
        partial("series_items_list", :layout => false, :format => :html)
      else 
        @annotation_count_array = SeriesItem.annotation_count_array
        display @series_items 
      end 
  end

  def show(id)
    @series_item = SeriesItem.get(id)
    raise NotFound unless @series_item
    @prev, @next = @series_item.prev_next
    display @series_item
  end

  protected
    def find_series_items(conditions, page)
      @series_items = SeriesItem.page(conditions, page, Constants::PER_PAGE)
    end

end
