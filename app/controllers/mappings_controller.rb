require 'csv'
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
      format.csv do 
        csv = CSV.generate do |csv|
          csv << ["Title", "Old Url", "New Url", "Status", "Notes", "Group", "Name", "Whole Tag"]
          apply_scopes(Mapping).all.each do |mapping|
            tag_group = []
            tag_name = []
            tag_whole_tag = []
            mapping.tags.each do |tag|
              tag_group << tag.group
              tag_name << tag.name
              tag_whole_tag << tag.whole_tag
            end
            csv << [mapping.title, mapping.old_url, mapping.new_url, mapping.status, mapping.notes, tag_group.join(' '), tag_name.join(' '), tag_whole_tag.join(' ')]
          end
        end
        send_data(csv, :type => 'test/csv', :filename => 'migratorator_mappings.csv') 
      end
    end

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
      referer = Rails.application.routes.recognize_path(request.referer) rescue nil
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
