Given /^a mapping exists$/ do
  @mapping = Mapping.create! :old_url => 'http://example.com/a_long_uri', :new_url => 'http://new.com/test'
end

Given /^many mappings exist$/ do
  @mappings = FactoryGirl.create_list(:mapping, 10)
  Mapping.save_tags_index! # force tags index update
end

Given /^mappings exist with the tag (.*)$/ do |tag|
  @mappings = FactoryGirl.create_list(:mapping, 10, :tags => [tag])
  Mapping.save_tags_index! # force tags index update
end

When /^I visit the mappings list$/ do
  visit mappings_path
end

When /^I filter by the tag (.*)$/ do |tag|
  filter_by_tag(tag)
end

Then /^I should see mappings$/ do
  check_mapping_details_appear_in_the_list(@mappings)
end

Then /^I should see the correct tags in the list$/ do
  check_tags_appear_in_the_tags_list_for(@mappings)
end

Then /^I should only see mappings with the tag (.*) in the list$/ do |tag|
  check_mapping_details_appear_in_the_list(@mappings, :tag => tag)
end