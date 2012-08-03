class ApplicationController < ActionController::Base
  protect_from_forgery

  include GDS::SSO::ControllerMethods

  before_filter :authenticate_user!, :unless => :format_is_csv?
  before_filter :require_signin_permission!, :unless => :format_is_csv?

  def format_is_csv?
    request.format.csv? 
  end

end
