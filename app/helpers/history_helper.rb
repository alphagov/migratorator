module HistoryHelper

  def format_history_value(field, value)
    value.blank? ? "&nbsp;".html_safe : value
  end

  def format_history_field(field)
    case field
    when 'tags_list_cache' then "Tags"
    else
      field.humanize
    end
  end

end