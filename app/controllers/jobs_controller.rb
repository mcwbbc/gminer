class JobsController < ApplicationController

  before_filter :check_cancel, :only => [:create, :update]
  before_filter :admin_required

  def index
    create_status_dropdown
    page = (params[:page].to_i > 0) ? params[:page] : 1

    case @status
      when "Active"
        cstring = "jobs.worker_key IS NOT NULL AND jobs.started_at IS NOT NULL AND jobs.finished_at IS NULL"
      when "Finished"
        cstring = "jobs.worker_key IS NULL AND jobs.started_at IS NOT NULL AND jobs.finished_at IS NOT NULL"
      when "Pending"
        cstring = "jobs.worker_key IS NULL AND jobs.started_at IS NULL AND jobs.finished_at IS NULL"
    end
    conditions = [cstring]

    find_jobs(conditions, page)
    #if we have a page > the last one, redo the query turning the page into the last one
    find_jobs(conditions, @jobs.total_pages) if params[:page].to_i > @jobs.total_pages

    respond_to do |format|
      format.html {}
      format.js  {
          render(:partial => "jobs_list")
        }
    end
  end

  def statistics
    @results_hash = Job.get_statistics
  end

  def new
    @job = Job.new
  end

  def create
    flash[:notice] = "Jobs have been created."
    redirect_to(jobs_url)
  end

  protected
    def find_jobs(conditions, page)
      @jobs = Job.page(conditions, page, Constants::PER_PAGE)
    end

    def check_cancel
      redirect_to(jobs_url) and return if (params[:commit] == t('label.cancel'))
    end

    def create_status_dropdown
      @status = params[:status] ? params[:status] : "Pending"
    end

end
