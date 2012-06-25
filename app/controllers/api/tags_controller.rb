class Api::TagsController < Api::BaseController

  respond_to :json

  has_scope :by_group, :as => :group

  def index
    @tags = apply_scopes(Tag).page(params[:page]).per(100).all
    respond_with @tags
  end

end