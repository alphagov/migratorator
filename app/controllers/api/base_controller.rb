class Api::BaseController < ApplicationController
  skip_before_filter :authenticate_user!
  skip_before_filter :require_signin_permission!
end