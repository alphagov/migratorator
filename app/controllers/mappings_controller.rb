class MappingsController < ApplicationController

  before_filter :find_mapping, :only => [:edit, :update]

  def index
    @tags_filter = params[:tags].split(",") if ! params[:tags].blank?
    context = @tags_filter.blank? ? Mapping : Mapping.tagged_with_all(@tags_filter)

    @tags = Tag.grouped
    @mappings = context.all

    respond_to do |format|
      format.html
      format.json
    end
  end

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

  def new
    @mapping = Mapping.new
  end

  def create
    respond_to do |format|
      format.json {
        @mapping = Mapping.new( JSON.parse params[:json] )

        if @mapping.save
          render :status => 201, :json => { :status => 201, :message => 'Mapping created.', :mapping => @mapping }
        else
          render :status => 422, :json => { :status => 422, :message => 'Unprocessable entity', :errors => @mapping.errors }
        end
      }
      format.html {
        @mapping = Mapping.new(params[:mapping])
        if @mapping.save
          flash[:success] = "Mapping created."
          redirect_to mappings_url
        else
          render :action => :new
        end
      }
    end
  end

  def edit; end

  def update
    respond_to do |format|
      format.json {
        if @mapping.update_attributes( JSON.parse params[:json] )
          render :status => 200, :json => { :status => 201, :message => 'Mapping updated.', :mapping => @mapping }
        else
          render :status => 422, :json => { :status => 422, :message => 'Unprocessable entity', :errors => @mapping.errors }
        end
      }
      format.html {
        if @mapping.update_attributes( params[:mapping] )
          flash[:success] = "Mapping updated."
          redirect_to mappings_url
        else
          render :action => :edit
        end
      }
    end
  end

  private
    def find_mapping
      @mapping = Mapping.find(params[:id])
    end

end