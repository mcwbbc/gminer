class SamplesController < ApplicationController

  def index
    @q = params[:query]
    page = (params[:page].to_i > 0) ? params[:page] : 1
    q_front = "#{@q}%"
    q_both = "%#{@q}%"
    cstring = "geo_accession LIKE ? OR title LIKE ? OR description LIKE ?"
    conditions = [cstring, q_front, q_both, q_both]
    find_samples(conditions, page)
    #if we have a page > the last one, redo the query turning the page into the last one
    find_samples(conditions, @samples.total_pages) if params[:page].to_i > @samples.total_pages

    respond_to do |format|
      format.html {
          @annotation_count_array = Sample.annotation_count_array
        }
      format.js  {
          render(:partial => "samples_list")
        }
    end
  end

  def show
    @sample = Sample.first(:conditions => {:geo_accession => params[:id]})
    raise ActiveRecord::RecordNotFound if !@sample

    if admin_logged_in?
      @new_annotation = Annotation.for_item(@sample, current_user.id)
      @ontologies = Ontology.all(:order => :name)
    end

    @prev, @next = @sample.prev_next
    respond_to do |format|
      format.html {
        @annotation_count_array = @sample.count_by_ontology_array
      }
    end
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "That sample does not exist."
      redirect_to(samples_url)
  end

  protected
    def find_samples(conditions, page)
      @samples = Sample.page(conditions, page, Constants::PER_PAGE)
    end

end
