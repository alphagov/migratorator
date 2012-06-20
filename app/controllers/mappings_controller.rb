class MappingsController < InheritedResources::Base

  respond_to :html, :json
  actions :index, :new, :create, :edit, :update

  has_scope :by_filter_path, :as => :tags
  has_scope :by_old_url, :as => :q

  before_filter :capture_referer_for_form, :only => :edit
  include MappingsHelper

  def index
    @filter = ! params[:tags].blank? ? params[:tags].split("/") : [ ]
    @context = apply_scopes(Mapping)

    @progress = Mapping.progress(@context, (params[:progress] || Tag::STATUS_DONE_TAG))
    @mappings = @context.page(params[:page]).all

    @tags = Tag.grouped

    respond_to do |format|
      format.html
      format.js
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
      success.html { redirect_to_previous_page_or_mappings_url }
    end
  end

  private
    def apply_tag_context(tags)
      @context ||= tags.any? ? Mapping.tagged_with_all(@tags_filter) : Mapping
    end

    def capture_referer_for_form
      referer = Rails.application.routes.recognize_path(request.referer)
      if referer
        session[referer_session_name(params[:id])] = referer
      end
    end

    def redirect_to_previous_page_or_mappings_url
      parameters = referer_session.dup
      session[referer_session_name(resource.id)] = nil
      redirect_to filter_mappings_path( parameters )
    end

end