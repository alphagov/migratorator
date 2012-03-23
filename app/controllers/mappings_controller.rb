class MappingsController < ApplicationController

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
    @mapping = Mapping.new( JSON.parse params[:json] )

    respond_to do |format|
      if @mapping.save
        format.json {
          render :status => 201, :json => { :status => 201, :message => 'Mapping created.', :mapping => @mapping }
        }
      else
        format.json {
          render :status => 422, :json => { :status => 422, :message => 'Unprocessable entity', :errors => @mapping.errors }
        }
      end
    end
  end

end