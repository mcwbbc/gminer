class PlatformsController < ApplicationController

  before_filter :admin_required, :only => [:skip_annotations]

  def index
    @q = params[:query]
    page = (params[:page].to_i > 0) ? params[:page] : 1
    q_front = "#{@q}%"
    q_both = "%#{@q}%"
    cstring = "geo_accession LIKE ? OR organism LIKE ?"
    conditions = [cstring, q_front, q_both]
    find_platforms(conditions, page)
    #if we have a page > the last one, redo the query turning the page into the last one
    find_platforms(conditions, @platforms.total_pages) if params[:page].to_i > @platforms.total_pages

    respond_to do |format|
      format.html {
          @annotation_count_array = Gminer::Platform.annotation_count_array
        }
      format.js  {
          render(:partial => "platforms_list")
        }
    end
  end

  def show
    @platform = Gminer::Platform.first(:conditions => {:geo_accession => params[:id]})
    raise ActiveRecord::RecordNotFound if !@platform

    if admin?
      @new_annotation = Annotation.for_item(@platform, current_user.id)
      @ontologies = Ontology.all(:order => :name)
      @top_tags = Tag.top_tags(@platform.tag_list)
      @all_tags = Tag.all_tags(@platform.tag_list).map(&:name)
      @prev, @next = @platform.prev_next
    end

    respond_to do |format|
      format.html {
        @annotation_count_array = @platform.count_by_ontology_array
      }
    end
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "That platform does not exist."
      redirect_to(platforms_url)
  end

  def skip_annotations
    platform = Gminer::Platform.where(:geo_accession => params[:geo_accession]).first
    status = params[:status]
    platform.set_children_status_to(status)
    render(:json => "Set status for #{platform.geo_accession} to #{status}".to_json)
  end

  protected
    def find_platforms(conditions, page)
      @platforms = Gminer::Platform.page(conditions, page, Constants::PER_PAGE)
    end

end
