class AnnotationsController < ApplicationController

  before_filter :admin_required, :only => [:audit, :valid, :invalid, :curate]

  def audit
    set_ontology_dropdown
    set_status_dropdown
    set_geotype_dropdown
    @q = params[:query]
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

    cstring << set_geotype_conditions(@geotype)

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
    set_ontology_dropdown
    set_geotype_dropdown
    @q = params[:query]
    page = (params[:page].to_i > 0) ? params[:page] : 1

    q_front = "#{@q}%"
    cstring = "ontology_terms.name LIKE ? AND ontologies.ncbo_id = ?"
    cstring << set_geotype_conditions(@geotype)

    conditions = [cstring, q_front, @current]
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

  def create
    annotation = Annotation.new(params[:annotation])
    term_id = "#{annotation.ncbo_id}|#{annotation.ncbo_term_id}"
    term = OntologyTerm.first(:conditions => {:term_id => term_id})
    ontology = Ontology.first(:conditions => {:ncbo_id => annotation.ncbo_id})

    annotation.ontology_id = ontology.id
    annotation.ontology_term_id = term.id

    respond_to do |format|
      format.js {
        if annotation.save
          render(:json => {'status' => "success", 'message' => "Annotation successfully saved!"})
        else
          errors = annotation.errors.full_messages.join("\n")
          render(:json => {'status' => "failure", 'message' => "ERROR: #{errors}"})
        end
      }
    end
    rescue Exception => e
      render(:json => {'status' => "failure", 'message' => "ERROR: #{e.inspect}"})
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
    @invalid = params[:invalid] || false
    @annotation_hash, @anatomy_terms, @rat_strain_terms, @sample_count = Annotation.build_cloud(params[:term_array], @invalid)

    respond_to do |format|
      format.html {}
      format.js  {}
    end
  end

  protected
    def find_annotations(conditions, page, per_page=Constants::PER_PAGE)
      @annotations = Annotation.page(conditions, page, per_page)
    end

    def set_ontology_dropdown
      @current = params[:ddown] ? params[:ddown] : Annotation.first ? Annotation.first.ncbo_id : ""
    end

    def set_geotype_dropdown
      @geotype = params[:geotype] ? params[:geotype] : "All"
    end

    def set_status_dropdown
      @status = params[:status] ? params[:status] : "Unaudited"
    end

    def set_geotype_conditions(geotype)
      case geotype
        when "All"
          ""
        when "Platform"
          " AND annotations.geo_accession LIKE 'GPL%'"
        when "Sample"
          " AND annotations.geo_accession LIKE 'GSM%'"
        when "Series"
          " AND annotations.geo_accession LIKE 'GSE%'"
        when "Dataset"
          " AND annotations.geo_accession LIKE 'GDS%'"
      end
    end

end
