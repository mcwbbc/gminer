class OntologyTermsController < ApplicationController

  def index
    @q = params[:query]
    page = (params[:page].to_i > 0) ? params[:page] : 1

    q_front = "#{@q}%"
    q_both = "%#{@q}%"

    cstring = "name LIKE ?"
    conditions = [cstring, q_front]

    find_ontology_terms(conditions, page)
    #if we have a page > the last one, redo the query turning the page into the last one
    find_ontology_terms(conditions, @ontology_terms.total_pages) if params[:page].to_i > @ontology_terms.total_pages

    respond_to do |format|
      format.html { }
      format.js  {
          render(:partial => "ontology_terms_list")
        }
    end
  end

  def show
    @ontology_term = OntologyTerm.first(:conditions => {:term_id => CGI::unescape(params[:id])})
    raise ActiveRecord::RecordNotFound if !@ontology_term
    @direct_geo = @ontology_term.direct_geo_references
    @closure_geo = @ontology_term.closure_geo_references
    @parent_closures = @ontology_term.parent_closures
    @child_closures = @ontology_term.child_closures

    respond_to do |format|
      format.html { }
      format.xml  { }
    end

    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "That ontology term does not exist."
      redirect_to(ontology_terms_url)
  end

  protected
    def find_ontology_terms(conditions, page)
      @ontology_terms = OntologyTerm.page(conditions, page, Constants::PER_PAGE)
    end

end
