class TagsController < ApplicationController

  respond_to :json

  def index
    @tags = Tag.all

    respond_with @tags
  end

end