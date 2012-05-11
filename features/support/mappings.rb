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
      "notes"         => mapping.notes,
      "search_query"  => mapping.search_query,
      "tags"          => mapping.tags.map(&:whole_tag),
      "related_links" => mapping.related_links
    }
  }.to_json

  api_response.should == json
end

def check_mapping_appears_in_the_list(mappings, options = {})
  mappings.each do |mapping|
    within("table") do
      page.should have_content(mapping.title)
      page.should have_content(mapping.status)
      page.should have_content(options[:tag]) if options and options[:tag]
      page.should have_link("Edit", :href => edit_mapping_path(mapping))
    end
  end
end

def check_mappings_do_not_appear_in_the_list_with_tag(tag)
  visit mappings_path
  within("table") do
    page.should_not have_content(tag)
  end
end

def check_multiple_mappings_appear_in_the_list(mappings, options = {})
  mappings.each do |mapping|
    within("tr#mapping_#{mapping.id}") do
      page.should have_content(mapping.title)
      page.should have_content(mapping.status)
      page.should have_content(options[:tag]) if options and options[:tag]
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

def filter_by_tag(tag)
  within("ul.tags-list") do
    click_link tag
  end
end

def fill_in_mapping_details(mapping)
  fill_in "Title", :with => mapping.title
  fill_in "Old URL", :with => mapping.old_url
  fill_in "New URL", :with => mapping.new_url
  select mapping.status, :from => "Status"
  fill_in "Tags", :with => mapping.tags

  within("#related-links") do
    click_link "Add a link"
    fill_in "Link Title", :with => "A Related Link"
    fill_in "URL", :with => "http://example.com/"
  end

  click_button "Create Mapping"
end