class ProbesetsController < ApplicationController

  def index
    @q = params[:query]
    page = (params[:page].to_i > 0) ? params[:page] : 1
    q_front = "#{@q}%"
    cstring = "name LIKE ?"
    conditions = [cstring, q_front]
    find_probesets(conditions, page)
    #if we have a page > the last one, redo the query turning the page into the last one
    find_probesets(conditions, @probesets.total_pages) if params[:page].to_i > @probesets.total_pages

    @platform_hash = Probeset.generate_platform_hash(@probesets)

    respond_to do |format|
      format.html {}
      format.csv {}
      format.js  {
          render(:partial => "probesets_list")
        }
    end
  end

  def show
    # we need to convert the back slashes to forward slashes so we can find the name properly
    probeset_id = params[:id] ? params[:id].gsub("\\", "/") : ""
    @probeset = Probeset.first(:conditions => {:name => probeset_id})
    raise ActiveRecord::RecordNotFound if !@probeset

    @term_array = @probeset.generate_term_array
    @chart_image = @term_array.any? ? @probeset.generate_gooogle_chart(@term_array) : ""

    respond_to do |format|
      format.html
      format.csv
    end
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "That probeset does not exist."
      redirect_to(probesets_url)
  end

  protected
    def find_probesets(conditions, page)
      @probesets = Probeset.page(conditions, page, Constants::PER_PAGE)
    end
end
