class Samples < Application

  def index
    provides :js 
    @q = params[:query]
    page = (params[:page].to_i > 0) ? params[:page] : 1

    q_front = "#{@q}%"
    q_both = "%#{@q}%"

    cstring = "geo_accession LIKE ? OR title LIKE ? OR description LIKE ?"
    conditions = [cstring, q_front, q_both, q_both]

    find_samples(conditions, page)
    #if we have a page > the last one, redo the query turning the page into the last one
    find_samples(conditions, @samples.total_pages) if params[:page].to_i > @samples.total_pages

    case content_type 
      when :js
        partial("samples_list", :layout => false, :format => :html)
      else 
        @annotation_count_array = Sample.annotation_count_array
        display @samples 
      end 
  end

  def show(id)
    @sample = Sample.get(id)
    raise NotFound unless @sample
    @prev, @next = @sample.prev_next
    display @sample
  end

  protected
    def find_samples(conditions, page)
      @samples = Sample.page(conditions, page, Constants::PER_PAGE)
    end

end
