class ResultsController < ApplicationController

  before_filter :admin_required

  def index
    @q = params[:query]
    page = (params[:page].to_i > 0) ? params[:page] : 1

    q_front = "#{@q}%"

    cstring = "results.sample_id = samples.id AND samples.geo_accession LIKE ?"
    conditions = [cstring, q_front]

    find_results(conditions, page)
    #if we have a page > the last one, redo the query turning the page into the last one
    find_results(conditions, @results.total_pages) if params[:page].to_i > @results.total_pages

    respond_to do |format|
      format.html { }
      format.js  {
          render(:partial => "results_list")
        }
    end
  end

  def show
    @result = Result.find(params[:id])

    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "That result does not exist."
      redirect_to(results_url)
  end

  protected
    def find_results(conditions, page)
      @results = Result.page(conditions, page, Constants::PER_PAGE)
    end

end
