class TagsController < InheritedResources::Base

  respond_to :html, :json
  actions :all, :except => :show

  has_scope :without_excluded_sections, :as => :exclude, :type => :boolean

  protected
    def resource
      @tag ||= Tag.find_by_string(params[:id])
    end

end