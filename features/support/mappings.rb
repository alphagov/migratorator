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