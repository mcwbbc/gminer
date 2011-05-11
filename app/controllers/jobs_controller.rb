class JobsController < ApplicationController

  before_filter :check_cancel, :only => [:create, :update]
  before_filter :admin_required, :except => [:status]

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

  def new
    ontology = Ontology.first
    geo_type = Constants::GEO_TYPES.first
    @job = Job.new(:geo_type => geo_type, :ontology => ontology)
    @fields = @job.get_fields
  end

  def create
    job = Job.new(params[:job])
    fields = params[:fields] || []

    fields.each do |field_name|
      job.geo_item_model.find_in_batches(:select => "id, geo_accession") do |group|
        group.each do |geo_item|
          Job.create_for(geo_item.geo_accession, job.ontology_id, field_name)
        end
      end
    end

    flash[:notice] = "Jobs have been created."
    redirect_to(jobs_url)
  end

  def update_job_form
    job = Job.new(params[:job])
    @fields = job.get_fields
    render(:partial => "jobs/geo_type.html.haml")
  end

  def dashboard
  end

  def graph_status
    pending_count = Job.pending_count
    active_count = Job.active_count
    worker_count = Worker.count
    render(:json => {'pending' => pending_count, 'active' => active_count, 'workers' => worker_count}.to_json)
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
