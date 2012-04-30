module UrlHelper

  def format_url_for_display(url)
    truncate( URI(url).path ) unless url.blank?
  end

end