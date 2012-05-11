class TagsController < InheritedResources::Base

  respond_to :html, :json
  actions :all, :except => :show

  protected
    def resource
      @tag ||= Tag.find_by_string(params[:id])
    end

end