class Api::MappingsController < Api::BaseController

  respond_to :json

  has_scope :by_tags_list, :as => :tags
  has_scope :by_old_url, :as => :old_url
  has_scope :by_new_url, :as => :new_url

  rescue_from Mapping::MappingNotFound, :with => proc { render :status => 404, :json => { :status => 404, :message => 'Mapping not found.' } }

  def index
    @mappings = apply_scopes(Mapping).page(params[:page]).per(80).all
    respond_with @mappings
  end

  def show
    @mapping = Mapping.find_by_id(params[:id])
    respond_with @mapping
  end

  def random
    context = apply_scopes(Mapping)
    @mapping = context.skip( rand context.count ).first

    render 'show'
  end

end