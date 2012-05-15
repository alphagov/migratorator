class BrowserController < ApplicationController

  def index
    @tags = params[:tags]
  end

end