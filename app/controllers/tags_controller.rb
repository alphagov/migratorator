class TagsController < ApplicationController

  respond_to :json

  def index
    @tags = Tag.all

    respond_with @tags
  end

  def create
    @tag = Tag.create_from_string( JSON.parse(params[:json])["tag"] )

    respond_to do |format|
      if @tag.persisted?
        format.json {
          render :status => 201, :json => { :status => 201, :message => 'Mapping created.', :mapping => @tag }
        }
      else
        format.json {
          render :status => 422, :json => { :status => 422, :message => 'Unprocessable entity', :errors => @tag.errors }
        }
      end
    end
  end

end