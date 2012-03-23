module ApplicationHelper

  def mapping_path(mapping)
    super({ :format => :json, :old_url => mapping.old_url })
  end

end
