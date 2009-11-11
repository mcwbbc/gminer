class PlatformsController < ApplicationController

  def index
    @q = params[:query]
    page = (params[:page].to_i > 0) ? params[:page] : 1
    q_front = "#{@q}%"
    q_both = "%#{@q}%"
    cstring = "geo_accession LIKE ? OR organism LIKE ?"
    conditions = [cstring, q_front, q_both]
    find_platforms(conditions, page)
    #if we have a page > the last one, redo the query turning the page into the last one
    find_platforms(conditions, @platforms.total_pages) if params[:page].to_i > @platforms.total_pages

    respond_to do |format|
      format.html {
          @annotation_count_array = Platform.annotation_count_array
        }
      format.js  {
          render(:partial => "platforms_list")
        }
    end
  end

  def show
    @platform = Platform.first(:conditions => {:geo_accession => params[:id]})
    raise ActiveRecord::RecordNotFound if !@platform
    @prev, @next = @platform.prev_next
    respond_to do |format|
      format.html {
        @annotation_count_array = @platform.count_by_ontology_array
      }
    end
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "That platform does not exist."
      redirect_to(platforms_url)
  end

  protected
    def find_platforms(conditions, page)
      @platforms = Platform.page(conditions, page, Constants::PER_PAGE)
    end

end
