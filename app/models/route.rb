class Route
  include Mongoid::Document

  field :old_resource, type: String
  field :new_resource, type: String

  def self.find_by_old_resource(param)
    raise ResourceNotProvided.new if !param or param.empty?
    self.where( old_resource: param ).first || raise(RouteNotFound.new)
  end

  class RouteNotFound < Exception; end
  class ResourceNotProvided < Exception; end

end