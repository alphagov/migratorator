module UrlHelper

  def format_url_for_display(url)
    URI(url).path unless url.blank?
  end

  def humanize_url(url)
    url.sub(/https?:\/\//,'')
  end

end