object false

@mappings.each do |mapping|
  node(mapping.old_url) {{id: mapping.id, title: mapping.title, old_url: mapping.old_url, status: mapping.status, new_url: mapping.new_url}}
end