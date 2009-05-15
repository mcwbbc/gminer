class Platforms < Application

  def index
    provides :js 
    @q = params[:query]
    page = (params[:page].to_i > 0) ? params[:page] : 1

    q_front = "#{@q}%"
    q_both = "%#{@q}%"

    cstring = "geo_accession LIKE ? OR organism LIKE ?"
    conditions = [cstring, q_front, q_both]

    find_platforms(conditions, page)
    #if we have a page > the last one, redo the query turning the page into the last one
    find_platforms(conditions, @platforms.total_pages) if params[:page].to_i > @platforms.total_pages

    case content_type 
      when :js
        partial("platforms_list", :layout => false, :format => :html)
      else 
        @annotation_count_array = Platform.annotation_count_array
        display @platforms 
      end 
  end

  def show(id)
    @platform = Platform.first(:geo_accession => id)
    raise NotFound unless @platform
    @prev, @next = @platform.prev_next
    display @platform
  end

  protected
    def find_platforms(conditions, page)
      @platforms = Platform.page(conditions, page, Constants::PER_PAGE)
    end

end
