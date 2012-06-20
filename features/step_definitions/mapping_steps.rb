Given /^a mapping exists$/ do
  @mapping = Mapping.create! :old_url => 'http://example.com/a_long_uri', :new_url => 'http://www.gov.uk/test'
end

Given /^many mappings exist$/ do
  @mappings = FactoryGirl.create_list(:mapping, 10)
end

Given /^mappings exist with the tag (.*)$/ do |tag|
  @mappings = FactoryGirl.create_list(:mapping, 10, :tags => [tag])
end

When /^I visit the mappings list$/ do
  visit mappings_path
end

When /^I visit the new mappings form$/ do
  visit new_mapping_path
end

When /^I edit the mapping$/ do
  visit edit_mapping_path(@mapping)
end

When /^I filter by the tag (.*)$/ do |tag|
  filter_by_tag(tag)
end

When /^I enter the mapping details into the form$/ do
  @mapping = OpenStruct.new({
    :title => "Example Mapping",
    :old_url => "http://foo.com/test",
    :new_url => "http://www.gov.uk/example",
    :status => "301",
    :tags => "example"
  })

  fill_in_mapping_details(@mapping)
end

When /^I mark the mapping as reviewed$/ do
  mark_mapping_as_reviewed
end

Then /^I should see mappings$/ do
  check_multiple_mappings_appear_in_the_list(@mappings)
end

Then /^I should see the correct tags in the list$/ do
  check_tags_appear_in_the_tags_list_for(@mappings)
end

Then /^I should only see mappings with the tag (.*) in the list$/ do |tag|
  check_multiple_mappings_appear_in_the_list(@mappings, :tag => tag)
end

Then /^I should see the mapping in the list$/ do
  check_mapping_appears_in_the_list [ @mapping ]
end

Then /^the mapping should be created$/ do
  page.should have_content("Mapping was successfully created")
  @mapping = Mapping.find_by_old_url(@mapping.old_url)
end

Then /^the mapping should be updated$/ do
  page.should have_content("Mapping was successfully updated")
  @mapping = Mapping.find_by_old_url(@mapping.old_url)
end

Then /^mappings should not exist with the tag$/ do
  check_mappings_do_not_appear_in_the_list_with_tag(@tag)
end

Then /^the mapping should be marked as reviewed$/ do
  check_the_mapping_is_reviewed
end