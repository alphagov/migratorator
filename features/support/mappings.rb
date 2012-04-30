def api_response
  source
end

def check_mapping_details_appear_in_the_api(mapping)
  json = {
    "mapping" => {
      "id"           => mapping.id,
      "title"         => mapping.title,
      "old_url"       => mapping.old_url,
      "status"        => mapping.status,
      "new_url"       => mapping.new_url,
      "tags"          => mapping.tags_array,
      "notes"         => mapping.notes,
      "search_query"  => mapping.search_query,
      "related_links" => mapping.related_links
    }
  }.to_json

  api_response.should == json
end

def check_mapping_details_appear_in_the_list(mappings)
  mappings.each do |mapping|
    within("tr#mapping_#{mapping.id}") do
      page.should have_content(mapping.title)
      page.should have_content(mapping.status)
      page.should have_link("Edit", :href => edit_mapping_path(mapping))
    end
  end
end

def check_tags_appear_in_the_tags_list_for(mappings)
  mappings.each do |mapping|
    mapping.tags.each do |tag|
      within("ul.tags-list") do
        page.should have_link(tag[:name])
        page.should have_selector(".nav-header", :text => (tag[:type] || "other").capitalize)
      end
    end
  end
end