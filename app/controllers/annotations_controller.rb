class AnnotationsController < ApplicationController

  before_filter :admin_required, :only => [:audit, :valid, :invalid, :curate]

  def audit
    create_ontology_dropdown
    create_status_dropdown
    @q = params[:query]
    @status= params[:status]
    page = (params[:page].to_i > 0) ? params[:page] : 1
    q_front = "#{@q}%"
    cstring = "ontology_terms.name LIKE ? AND ontologies.ncbo_id = ?"

    case @status
      when "All"
      when "Valid"
        cstring << " AND annotations.verified = 1"
      when "Invalid"
        cstring << " AND annotations.verified = 0 AND annotations.audited = 1"
      when "Unaudited"
        cstring << " AND annotations.audited = 0"
    end

    conditions = [cstring, q_front, @current]
    find_annotations(conditions, page, 50)
    #if we have a page > the last one, redo the query turning the page into the last one
    find_annotations(conditions, @annotations.total_pages, 50) if params[:page].to_i > @annotations.total_pages

    respond_to do |format|
      format.html { }
      format.js  {
          render(:partial => "audit_list")
        }
    end
  end


  def index
    create_ontology_dropdown
    @q = params[:query]
    page = (params[:page].to_i > 0) ? params[:page] : 1
    q_both = "%#{@q}%"
    cstring = "ontology_terms.name LIKE ? AND ontologies.ncbo_id = ?"
    conditions = [cstring, q_both, @current]
    find_annotations(conditions, page)
    #if we have a page > the last one, redo the query turning the page into the last one
    find_annotations(conditions, @annotations.total_pages) if params[:page].to_i > @annotations.total_pages

    respond_to do |format|
      format.html {
          @annotation_count_array = Annotation.count_by_ontology_array
        }
      format.js  {
          render(:partial => "annotations_list")
        }
    end
  end

  # GET /datasets/1
  def show
    @annotation = Annotation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "That annotation does not exist."
      redirect_to(annotations_url)
  end

  def valid
    ids = params[:selected_annotations]
    Annotation.update_all("verified = 1, audited = 1", "id IN (#{ids.join(',')})") if ids
    render(:json => ids.to_json)
  end

  def invalid
    ids = params[:selected_annotations]
    Annotation.update_all("verified = 0, audited = 1", "id IN (#{ids.join(',')})") if ids
    render(:json => ids.to_json)
  end

  def curate
    annotation = Annotation.find(params[:id])
    annotation.toggle
    hash = {:result => annotation.verified?}
    render(:json => hash.to_json)
  end

  # allow searching of annotation using clouds of anatomy and rat strains
  def cloud
    @annotation_hash, @anatomy_terms, @rat_strain_terms = Annotation.build_cloud(params[:term_array])

    respond_to do |format|
      format.html {
          @annotation_count_array = Annotation.count_by_ontology_array
        }
      format.js  {}
    end
  end

  protected
    def find_annotations(conditions, page, per_page=Constants::PER_PAGE)
      @annotations = Annotation.page(conditions, page, per_page)
    end

    def create_ontology_dropdown
      @current = params[:ddown] ? params[:ddown] : "1000"
    end

    def create_status_dropdown
      @status = params[:status] ? params[:status] : "Unaudited"
    end

end
