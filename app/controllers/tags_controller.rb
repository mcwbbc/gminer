class TagsController < ApplicationController

  before_filter :check_cancel, :only => [:create, :update]
  before_filter :admin_required

  def index
    @q = params[:query]
    page = (params[:page].to_i > 0) ? params[:page] : 1

    q_front = "#{@q}%"

    cstring = "name LIKE ?"
    conditions = [cstring, q_front]

    find_tags(conditions, page)
    #if we have a page > the last one, redo the query turning the page into the last one
    find_tags(conditions, @tags.total_pages) if params[:page].to_i > @tags.total_pages

    respond_to do |format|
      format.html {
        }
      format.js  {
          render(:partial => "tags_list.html.haml")
        }
    end
  end

  def new
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(params[:tag])
    if @tag.save
      flash[:notice] = "Tag has been created."
      redirect_to(tags_url)
    else
      render(:action => :new)
    end
  end

  def create_for
    @item = Tag.process_tagging('create', params[:geo_accession], params[:tag_list])
    @top_tags = Tag.top_tags(@item.tag_list)
    @all_tags = Tag.all_tags(@item.tag_list).map(&:name)
    render(:action => "update.js.haml")
  end

  def show
    @tag = Tag.find(params[:id])

    respond_to do |format|
      format.html
    end

    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "That tag does not exist."
      redirect_to(tags_url)
  end

  def edit
    @tag = Tag.find(params[:id])

    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "That tag does not exist."
      redirect_to(tags_url)
  end

  def update
    @tag = Tag.find(params[:id])

    if @tag.update_attributes(params[:tag])
      flash[:notice] = 'Tag was successfully updated.'
      redirect_to(tags_url)
    else
      render(:action => :edit)
    end
  end

  def destroy
  end

  def delete_for
    @item = Tag.process_tagging('delete', params[:geo_accession], params[:tag_list])
    @top_tags = Tag.top_tags(@item.tag_list)
    @all_tags = Tag.all_tags(@item.tag_list).map(&:name)
    render(:action => "update.js.haml")
  end


  protected

    def find_tags(conditions, page)
      @tags = Tag.page(conditions, page, Constants::PER_PAGE)
    end

    def check_cancel
      redirect_to(tags_url) and return if (params[:commit] == t('label.cancel'))
    end

end
