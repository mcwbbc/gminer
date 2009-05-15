class Annotations < Application

  def index
    provides :js 
    create_ontology_dropdown
    @q = params[:query]
    page = (params[:page].to_i > 0) ? params[:page] : 1

    q_both = "%#{@q}%"

    cstring = "ontology_terms.name LIKE ? AND ontologies.name = ?"
    conditions = [cstring, q_both, @current]

    find_annotations(conditions, page)
    #if we have a page > the last one, redo the query turning the page into the last one
    find_annotations(conditions, @annotations.total_pages) if params[:page].to_i > @annotations.total_pages

    case content_type 
      when :js
        partial("annotations_list", :layout => false, :format => :html)
      else
        @annotation_count_array = Annotation.count_by_ontology_array
        display @annotations 
      end 
  end

  def show(id)
    @annotation = Annotation.get(id)
    raise NotFound unless @annotation
    display @annotation
  end

  def curate(ontology_term_id, geo_accession, field)
    only_provides :js

    annotation = Annotation.first(:ontology_term_id => ontology_term_id, :geo_accession => geo_accession, :field => field)
    annotation.toggle
    hash = {:result => annotation.verified?}
    display hash
  end

  # allow searching of annotation using clouds of anatomy and rat strains
  def cloud
    provides :js
    @annotation_hash, @anatomy_terms, @rat_strain_terms = Annotation.build_cloud(params[:term_array])
    case content_type 
      when :js
        render :layout => false
      else
        render
      end 
  end

  protected
    def find_annotations(conditions, page)
      @annotations = Annotation.page(conditions, page, Constants::PER_PAGE)
    end

    def create_ontology_dropdown
      @current = params[:ddown] ? params[:ddown] : "Rat Strain Ontology"
    end

end
