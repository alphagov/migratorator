object false

@mappings.each do |mapping|
  node(mapping.id.to_s.to_sym) {{id: mapping.id, title: mapping.title, old_url: mapping.old_url, status: mapping.status, new_url: mapping.new_url}}
end
