def fill_in_tag_details(tag, operation = :create)
  fill_in "Tag", :with => tag.whole_tag
  click_button "#{operation.to_s.capitalize} Tag"
end

def check_multiple_tags_appear_in_the_list(tags)
  tags.each do |tag|
    within("tr#tag_#{tag.id}") do
      page.should have_content(tag.whole_tag)
      page.should have_link("Rename", :href => edit_tag_path(tag))
    end
  end
end

def check_tag_does_not_appear_in_the_list(tag)
  within("table") do
    page.should_not have_content(tag.whole_tag)
  end
end

def destroy_tag(tag)
  visit tags_path
  within("tr#tag_#{tag.id}") do
    click_link "Destroy"
  end
end

def check_tag_details_appear_in_the_api(tag)
  JSON.parse(api_response)["tags"].should be_include(object_for_tag tag)
end

def check_tag_details_do_not_appear_in_the_api(tag)
  JSON.parse(api_response)["tags"].should_not be_include(object_for_tag tag)
end

def object_for_tag(tag)
  {
    "tag" => {
      "group" => tag.group,
      "name" => tag.name,
      "whole_tag" => tag.whole_tag
    }
  }
end