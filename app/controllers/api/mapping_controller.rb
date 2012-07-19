class Api::MappingController < Api::BaseController

  respond_to :json

  rescue_from Mapping::MappingNotFound, :with => proc { render :status => 404, :json => { :status => 404, :message => 'Mapping not found.' } }

  def index
    @mapping = Mapping.find_by_old_url(params[:old_url])
    respond_with @mapping
  end

end
