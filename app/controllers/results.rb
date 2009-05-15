class Results < Application

  def index
    provides :js 
    @q = params[:query]
    page = (params[:page].to_i > 0) ? params[:page] : 1

    q_front = "#{@q}%"

    cstring = "results.sample_geo_accession LIKE ?"
    conditions = [cstring, q_front]

    find_results(conditions, page)
    #if we have a page > the last one, redo the query turning the page into the last one
    find_results(conditions, @results.total_pages) if params[:page].to_i > @results.total_pages

    case content_type 
      when :js
        partial("results_list", :layout => false, :format => :html)
      else 
        display @results 
      end 
  end

  def show(id)
    @result = Result.get(id)
    raise NotFound unless @result
    display @result
  end

  protected
    def find_results(conditions, page)
      @results = Result.page(conditions, page, Constants::PER_PAGE)
    end

end
