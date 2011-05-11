class AnnotationsController < ApplicationController

  before_filter :admin_required, :only => [:audit, :item_audit, :geo_item, :valid, :invalid, :curate, :top_curators]

  def top_curators
    @top_daily_curators = Annotation.top('curated_by_id', true)
    @top_alltime_curators = Annotation.top('curated_by_id')
    @top_alltime_creators = Annotation.top('created_by_id')
    @top_daily_creators = Annotation.top('created_by_id', true)
    render(:partial => "shared/top_curators.html.haml")
  end

  def audit
    set_ontology_dropdown
    set_status_dropdown
    set_geotype_dropdown
    set_has_predicate_dropdown

    @q = params[:query]
    page = (params[:page].to_i > 0) ? params[:page] : 1
    q_front = "#{@q}%"
    cstring = "annotations.term_name LIKE ? AND annotations.ncbo_id = ?"

    case @status
      when "All"
        cstring << " AND annotations.status != 'skip'"
      when "Valid"
        cstring << " AND annotations.verified = 1 AND annotations.status = 'audited'"
      when "Invalid"
        cstring << " AND annotations.verified = 0 AND annotations.status = 'audited'"
      when "Unaudited"
        cstring << " AND annotations.status = 'unaudited'"
    end

    cstring << set_geotype_conditions(@geotype)

    cstring << set_predicate_conditions(@has_predicate)

    conditions = [cstring, q_front, @current]
    find_annotations_for_curation(conditions, current_user.id)

    respond_to do |format|
      format.html { }
      format.js  {
          render(:partial => "annotations/audit_list.html.haml")
        }
    end
  end

  def item_audit
    set_geotype_dropdown
    set_exclude_dropdown
    @tags = params[:query] || []
    page = (params[:page].to_i > 0) ? params[:page] : 1

    conditions = ""

    find_geo_items(@geotype, @tags, conditions, @exclude, page, 25)
    #if we have a page > the last one, redo the query turning the page into the last one
    find_geo_items(@geotype, @tags, conditions, @exclude, @geo_items.total_pages, 25) if params[:page].to_i > @geo_items.total_pages

    respond_to do |format|
      format.html { }
      format.js  {
        render(:partial => "annotations/item_audit_list.html.haml")
      }
    end
  end

  def geo_item
    id = params[:id]
    geo_item = Sample.load_item(id) #Sample since we just need something that has the method

    respond_to do |format|
      format.js  {
          render(:partial => "annotations/audit_list_annotations.html.haml", :locals => {:items => geo_item.annotations})
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

  def create
    @annotation = Annotation.new(params[:annotation])
    term_id = "#{@annotation.ncbo_id}|#{@annotation.ncbo_term_id}"
    term = OntologyTerm.first(:conditions => {:term_id => term_id})
    ontology = Ontology.first(:conditions => {:ncbo_id => @annotation.ncbo_id})

    raise ActiveRecord::RecordNotFound, "Invalid ontology term" unless term
    raise ActiveRecord::RecordNotFound, "Invalid ontology" unless ontology

    @annotation.predicate = (ontology.ncbo_id == 1150) ? 'strain_used' : (ontology.ncbo_id == 1006) ? 'cell_used' : 'tissue'
    @annotation.term_id = term_id
    @annotation.term_name = term.name
    @annotation.ontology_id = ontology.id
    @annotation.ontology_term_id = term.id
    @annotation.identifier = [@annotation.geo_accession, @annotation.field_name, term_id].join("-")

    respond_to do |format|
      format.js {
        if @annotation.save
          Delayed::Job.enqueue(CreateClosureAnnotationsJob.new(@annotation.id))
          @result = {'status' => "success", 'message' => "Annotation successfully saved!"}
        else
          errors = @annotation.errors.full_messages.join("\n")
          @result = {'status' => "failure", 'message' => "ERROR: #{errors}"}
        end
      }
    end
    rescue Exception => e
      @result = {'status' => "failure", 'message' => "ERROR: #{e.inspect}"}
  end

  def mass_curate
    ids = params[:selected_annotations]
    verified = params[:verified]
    Annotation.update_all("verified = #{verified}, status = 'audited', curated_by_id = #{current_user.id}, updated_at = '#{Time.now}'", "id IN (#{ids.join(',')})") if ids
    render(:json => ids.to_json)
  end

  def curate
    annotation = Annotation.find(params[:id])
    annotation.set_status(current_user.id)
    hash = {:result => annotation.verified?, :css_class => "predicate-#{annotation.predicate}"}
    render(:json => hash.to_json)
  end

  def predicate
    annotation = Annotation.find(params[:id])
    annotation.predicate = params[:predicate]
    annotation.save
    hash = {:result => annotation.verified?, :css_class => "predicate-#{annotation.predicate}"}
    render(:json => hash.to_json)
  end

  # allow searching of annotation using clouds of anatomy and rat strains
  def cloud
    @page = (params[:page].to_i > 0) ? params[:page].to_i : 1
    @term_array = params[:term_array]
    @total_count, @annotations, @anatomy_terms, @rat_strain_terms = Annotation.build_cloud(@term_array, @page)

    respond_to do |format|
      format.html {}
      format.js  {}
    end
  end

  def destroy
    annotation = Annotation.find(params[:id])
    if annotation.destroy
      render(:json => {'status' => "success", 'message' => "Annotation successfully deleted."})
    else
      render(:json => {'status' => "failure", 'message' => "ERROR: #{e.inspect}"})
    end
  end

  protected
    def find_annotations_for_curation(conditions, user_id)
      @annotations = Annotation.find_for_curation(conditions, user_id)
    end

    def find_annotations(conditions, page, per_page=Constants::PER_PAGE)
      @annotations = Annotation.page(conditions, page, per_page)
    end

    def find_geo_items(geo_item, tags, conditions, exclude, page, per_page=Constants::PER_PAGE)
      mod = get_model(geo_item)
      @geo_items = mod.page_for_tags(tags, conditions, exclude, page, per_page)
    end

    def set_ontology_dropdown
      @current = params[:ddown] ? params[:ddown] : Annotation.first ? Annotation.first.ncbo_id : ""
    end

    def set_geotype_dropdown
      @geotype = params[:geotype] ? params[:geotype] : "All"
    end

    def set_exclude_dropdown
      @exclude = params[:exclude] ? params[:exclude] : false
    end

    def set_status_dropdown
      @status = params[:status] ? params[:status] : "Unaudited"
    end

    def set_has_predicate_dropdown
      @has_predicate = params[:has_predicate] ? params[:has_predicate] : 'No'
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

    def set_predicate_conditions(has_predicate)
      case has_predicate
        when "No"
          " AND predicate IS NULL"
        when "Yes"
          " AND predicate IS NOT NULL"
      end
    end

    def get_model(geotype)
      case geotype
        when "All"
          return Gminer::Platform
        when "Platform"
          return Gminer::Platform
        when "Sample"
          return Sample
        when "Series"
          return SeriesItem
        when "Dataset"
          return Dataset
      end
    end

end
