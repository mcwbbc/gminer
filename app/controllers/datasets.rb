class Datasets < Application

  def index
    provides :js 
    @q = params[:query]
    page = (params[:page].to_i > 0) ? params[:page] : 1

    q_front = "#{@q}%"
    q_both = "%#{@q}%"

    cstring = "geo_accession LIKE ? OR title LIKE ?"
    conditions = [cstring, q_front, q_both]

    find_datasets(conditions, page)
    #if we have a page > the last one, redo the query turning the page into the last one
    find_datasets(conditions, @datasets.total_pages) if params[:page].to_i > @datasets.total_pages

    case content_type 
      when :js
        partial("datasets_list", :layout => false, :format => :html)
      else 
        @annotation_count_array = Dataset.annotation_count_array
        display @datasets 
      end 
  end

  def show(id)
    @dataset = Dataset.first(:geo_accession => id)
    raise NotFound unless @dataset
    @prev, @next = @dataset.prev_next
    display @dataset
  end

  protected
    def find_datasets(conditions, page)
      @datasets = Dataset.page(conditions, page, Constants::PER_PAGE)
    end

end
