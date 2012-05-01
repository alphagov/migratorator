When /^I request a mapping from the API$/ do
  visit find_mapping_path(:old_url => @mapping.old_url, :format => 'json')
end

Then /^I should be able to see the information about the mapping$/ do
  check_mapping_details_appear_in_the_api(@mapping)
end

Then /^the API should be updated to show the mapping$/ do
  visit find_mapping_path(:old_url => @mapping.old_url, :format => 'json')
  check_mapping_details_appear_in_the_api(@mapping)
end