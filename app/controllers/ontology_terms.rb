class OntologyTerms < Application

  def index
    provides :js 
    @q = params[:query]
    page = (params[:page].to_i > 0) ? params[:page] : 1

    q_front = "#{@q}%"
    q_both = "%#{@q}%"

    cstring = "name LIKE ?"
    conditions = [cstring, q_front]

    find_ontology_terms(conditions, page)
    #if we have a page > the last one, redo the query turning the page into the last one
    find_ontology_terms(conditions, @ontology_terms.total_pages) if params[:page].to_i > @ontology_terms.total_pages

    case content_type 
      when :js
        partial("ontology_terms_list", :layout => false, :format => :html)
      else 
        display @ontology_terms 
      end 
  end

  def show(id)
    provides :xml

    @ontology_term = OntologyTerm.get(id)
    @direct_geo = @ontology_term.direct_geo_references
    @closure_geo = @ontology_term.closure_geo_references
    @parent_closures = @ontology_term.parent_closures
    @child_closures = @ontology_term.child_closures

    raise NotFound unless @ontology_term
    display @ontology_term
  end

  protected
    def find_ontology_terms(conditions, page)
      @ontology_terms = OntologyTerm.page(conditions, page, Constants::PER_PAGE)
    end

end
