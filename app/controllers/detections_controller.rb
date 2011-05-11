class DetectionsController < ApplicationController

  before_filter :admin_required

  def index
    @q = params[:query]
    page = (params[:page].to_i > 0) ? params[:page] : 1
    q_front = "#{@q}%"
    cstring = "probesets.name LIKE ?"
    conditions = [cstring, q_front]
    find_detections(conditions, page)
    #if we have a page > the last one, redo the query turning the page into the last one
    find_detections(conditions, @detections.total_pages) if params[:page].to_i > @detections.total_pages

    respond_to do |format|
      format.html {}
      format.csv {}
      format.js  {
          render(:partial => "detections_list")
        }
    end
  end

  def show
    sid, psid = params[:id].split("-")
    @detection = Detection.first(:conditions => {:probeset_id => psid, :sample_id => sid})

    respond_to do |format|
      format.html
      format.csv
    end
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "That detection does not exist."
      redirect_to(detections_url)
  end

  protected
    def find_detections(conditions, page)
      @detections = Detection.page(conditions, page, 50)
    end
end
