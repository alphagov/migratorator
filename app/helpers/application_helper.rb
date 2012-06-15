module ApplicationHelper

  def find_mapping_path(mapping)
    super({ :format => :json, :old_url => mapping.old_url })
  end

  def filter_group_from_tag(tag, group)
    tag.sub(/#{group}:/,'')
  end

  def normalize_title(title)
    title.sub(/ : Directgov( - .*)?$/,"") if title
  end

  def active_tags
    @tags_filter || []
  end

  def tag_is_active?(tag)
    active_tags.include?(tag.whole_tag)
  end

  def add_tag_to_filter_path(tag)
    new_tags = active_tags.dup
    new_tags.reject! {|t| Tag.parse_tag_from_string(t)[:group] == tag.group }

    new_tags << tag.whole_tag
    filter_mappings_path(:tags => new_tags.join('/'))
  end

  def remove_tag_from_filter_path(tag)
    new_tags = active_tags.dup
    new_tags.delete(tag.to_s)
    new_tags.any? ? filter_mappings_path(:tags => new_tags.join('/')) : mappings_path
  end
end
