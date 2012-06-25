When /^I request a mapping from the API$/ do
  visit api_mappings_path(:old_url => @mapping.old_url, :format => 'json')
end

Then /^I should be able to see the information about the mapping$/ do
  check_mapping_details_appear_in_the_api(@mapping)
end

Then /^the API should be updated to show the mapping$/ do
  visit api_mappings_path(:old_url => @mapping.old_url, :format => 'json')
  check_mapping_details_appear_in_the_api(@mapping)
end

Then /^the API should be updated to show the tag$/ do
  visit api_tags_path(:format => 'json')
  check_tag_details_appear_in_the_api(@tag)
end

Then /^the API should not show the tag$/ do
  visit api_tags_path(:format => 'json')
  check_tag_details_do_not_appear_in_the_api(@tag)
end