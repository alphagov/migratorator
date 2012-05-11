Given /^a tag exists$/ do
  @tag = FactoryGirl.create(:tag)
end

Given /^the tag (.*) exists$/ do |tag|
  @tag = FactoryGirl.create(:tag, :whole_tag => tag)
end

Given /^many tags exist$/ do
  @tags = FactoryGirl.create_list(:tag, 10)
end

When /^I visit the tags list$/ do
  visit tags_path
end

When /^I visit the new tag form$/ do
  visit new_tag_path
end

When /^I enter the tag details into the form$/ do
  @tag = FactoryGirl.build(:tag)

  fill_in_tag_details(@tag)
end

When /^I rename the tag$/ do
  visit edit_tag_path(@tag)
  fill_in_tag_details(OpenStruct.new({:whole_tag => "renamed_tag"}), :rename)
end

When /^I destroy the tag$/ do
  destroy_tag(@tag)
end

Then /^the tag should be created$/ do
  page.should have_content("Tag was successfully created.")
  @tag = Tag.find_by_string(@tag.whole_tag)
end

Then /^the tag should be renamed$/ do
  page.should have_content("Tag was successfully updated.")
  @tag.reload
end

Then /^the tag should be deleted$/ do
  page.should have_content("Tag was successfully destroyed.")
end

Then /^I should see all the tags in the list$/ do
  check_multiple_tags_appear_in_the_list(@tags)
end

Then /^I should see the tag in the list$/ do
  check_multiple_tags_appear_in_the_list([@tag])
end

Then /^the tag should not appear in the list$/ do
  check_tag_does_not_appear_in_the_list(@tag)
end

