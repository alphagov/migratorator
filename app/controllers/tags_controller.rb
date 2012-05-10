class TagsController < InheritedResources::Base

  respond_to :html, :json
  actions :all, :except => :show

  def create
    @tag = Tag.create_from_string(params[:tag])
    create!
  end

  protected
    def resource
      @tag ||= Tag.find_by_string(params[:id])
    end

end