class MappingsController < InheritedResources::Base

  respond_to :html, :json
  actions :index, :new, :create, :edit, :update

  def index
    @tags_filter = ! params[:tags].blank? ? params[:tags].split("/") : [ ]

    @context = apply_tag_context(@tags_filter)
    @progress = Mapping.progress(@tags_filter, (params[:progress] || Tag::STATUS_DONE_TAG))
    @mappings = @context.page(params[:page]).all

    @tags = Tag.without_excluded_sections.grouped

    respond_to do |format|
      format.html
      format.json { @mappings = @context.page(params[:page]).per(80).all }
    end
  end

  def show
    @mapping = Mapping.find_by_old_url params[:old_url]

    respond_to do |format|
      format.json {
        render 'show'
      }
    end
  rescue Mapping::MappingNotFound
    render :status => 404, :json => { :status => 404, :message => 'Mapping not found.' }
  rescue Mapping::URLNotProvided
    render :status => 400, :json => { :status => 400, :message => 'URL not provided.' }
  end

  def create
    create! do |success, failure|
      success.html { redirect_to mappings_url }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to mappings_url }
    end
  end

  private
    def apply_tag_context(tags)
      @context ||= tags.any? ? Mapping.tagged_with_all(@tags_filter) : Mapping
    end

end