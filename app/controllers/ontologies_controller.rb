class OntologiesController < ApplicationController

  before_filter :check_cancel, :only => [:create, :update]
  before_filter :admin_required, :only => [:new, :edit, :create, :update]

  def index
    @q = params[:query]
    page = (params[:page].to_i > 0) ? params[:page] : 1

    q_front = "#{@q}%"
    q_both = "%#{@q}%"

    cstring = "name LIKE ?"
    conditions = [cstring, q_front]

    find_ontologies(conditions, page)
    #if we have a page > the last one, redo the query turning the page into the last one
    find_ontologies(conditions, @ontologies.total_pages) if params[:page].to_i > @ontologies.total_pages

    respond_to do |format|
      format.html {}
      format.js  {
          render(:partial => "ontologies_list")
        }
    end
  end

  def new
    @ontology = Ontology.new
  end

  def create
    @ontology = Ontology.new(params[:ontology])
    if @ontology.save
      flash[:notice] = "Ontology has been created."
      redirect_to(ontologies_url)
    else
      render(:action => :new)
    end
  end

  def edit
    @ontology = Ontology.find(params[:id])

    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "That ontology does not exist."
      redirect_to(ontologies_url)
  end

  def update
    @ontology = Ontology.find(params[:id])

    if @ontology.update_attributes(params[:ontology])
      flash[:notice] = 'Ontology was successfully updated.'
      redirect_to(ontologies_url)
    else
      render(:action => :edit)
    end
  end

  def show
    @ontology = Ontology.find(params[:id])

    page = (params[:page].to_i > 0) ? params[:page].to_i : 1

    @q = params[:query]
    q_front = "#{@q}%"

    cstring = "ontology_id = ? AND name LIKE ?"
    conditions = [cstring, @ontology.id, q_front]

    find_ontology_terms(conditions, page)
    #if we have a page > the last one, redo the query turning the page into the last one
    find_ontology_terms(conditions, @ontology_terms.total_pages) if params[:page].to_i > @ontology_terms.total_pages

    respond_to do |format|
      format.html {}
      format.js  {
          render(:partial => "ontology_term_list.html.haml")
        }
    end

    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "That ontology does not exist."
      redirect_to(ontologies_url)
  end

  protected
    def find_ontologies(conditions, page)
      @ontologies = Ontology.page(conditions, page, Constants::PER_PAGE)
    end

    def find_ontology_terms(conditions, page)
      @ontology_terms = OntologyTerm.page_for_ontology(conditions, page, Constants::PER_PAGE)
    end

    def check_cancel
      redirect_to(ontologies_url) and return if (params[:commit] == t('label.cancel'))
    end

end
