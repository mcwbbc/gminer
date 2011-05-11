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
    annotation_type = params['annotation_type']
    page = (params[:page].to_i > 0) ? params[:page].to_i : 1
    raise ActiveRecord::RecordNotFound if !@ontology_term

    respond_to do |format|
      format.html {
        load_closure_data
        @direct_geo = Annotation.page(["annotations.verified = ? AND annotations.ontology_term_id = ?", true, @ontology_term.id])
        @closure_geo = AnnotationClosure.page(["annotations.verified = ? AND annotation_closures.ontology_term_id = ?", true, @ontology_term.id])
      }
      format.js {
        case annotation_type
          when 'direct'
            items = Annotation.page(["annotations.verified = ? AND annotations.ontology_term_id = ?", true, @ontology_term.id], page)
          else
            items = AnnotationClosure.page(["annotations.verified = ? AND annotation_closures.ontology_term_id = ?", true, @ontology_term.id], page)
        end
        render(:partial => "annotations.html.haml", :locals => {:annotation_type => annotation_type, :annotation_count => items.total_entries, :items => items})
      }
      format.xml  {
        load_closure_data
        load_all_geo_closures
      }
      format.csv  {
        load_closure_data
        load_all_geo_closures
        csv_string = CSV.generate do |csv|
          # header row
          csv << ["term_name", "term_id", "ontology_name", "ncbo_ontology_id", "term_source", "geo_accession", "sample_description"]

          # data rows
          @direct_geo.each do |annotation|
            csv << [@ontology_term.name, @ontology_term.term_id.split("|").last, @ontology_term.ontology.name, @ontology_term.ontology.ncbo_id, 'direct', annotation.geo_accession, annotation.description]
          end

          @closure_geo.each do |closure|
            csv << [@ontology_term.name, @ontology_term.term_id.split("|").last, @ontology_term.ontology.name, @ontology_term.ontology.ncbo_id, 'closure', closure.annotation.geo_accession, closure.annotation.description]
          end
        end

        filename = @ontology_term.term_id.split("|").last.gsub(":", "_")
        # send it to the browsah
        send_data(csv_string.force_encoding('UTF-8'), :type => 'text/csv; charset=UTF-8; header=present', :disposition => "attachment; filename=#{filename}.csv")
      }
    end

    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "That ontology term does not exist."
      redirect_to(ontology_terms_url)
  end

  protected
    def find_ontology_terms(conditions, page)
      @ontology_terms = OntologyTerm.page(conditions, page, Constants::PER_PAGE)
    end

    def load_closure_data
      @parent_closures = @ontology_term.parent_closures
      @child_closures = @ontology_term.child_closures
      @geo_counts = @ontology_term.geo_counts
    end

    def load_all_geo_closures
      @direct_geo = Annotation.all(:conditions => ["annotations.verified = ? AND annotations.ontology_term_id = ?", true, @ontology_term.id], :group => :geo_accession)
      @closure_geo = AnnotationClosure.all(:conditions => ["annotations.verified = ? AND annotation_closures.ontology_term_id = ?", true, @ontology_term.id], :include => [:annotation], :group => 'annotations.geo_accession')
    end

end
