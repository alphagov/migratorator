class Route
  include Mongoid::Document

  field :old_resource, type: String
  field :new_resource, type: String

  def self.find_by_old_resource(param)
    self.where( old_resource: param ).first || raise(RouteNotFound.new)
  end

  class RouteNotFound < Exception; end

end