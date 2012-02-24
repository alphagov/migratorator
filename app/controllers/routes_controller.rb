class RoutesController < ApplicationController

  def show
    @route = Route.find_by_old_resource params[:old_resource]

    respond_to do |format|
      format.json { 
        render :json => { :old_resource => @route.old_resource, :new_resource => @route.new_resource }.to_json
      }
    end
  rescue Route::RouteNotFound
    render :status => 404, :json => { :status => 404, :message => 'Route not found.' }
  end

end