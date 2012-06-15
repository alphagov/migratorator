module MappingsHelper
  def referer_session_name(id)
    "after_update_redirect_#{id}".to_sym
  end

  def referer_session
    @referer_session ||= (session[referer_session_name(resource.id)] || {}).select {|k,v| [:page, :tags].include?(k) }
  end
end