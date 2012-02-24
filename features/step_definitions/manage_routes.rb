Given /^a route exists$/ do
  @route = Route.create! :old_resource => 'http://example.com/a_long_uri', :new_resource => 'http://new.com/test'
end

When /^I request a route from the API$/ do
  visit route_path(:old_resource => @route.old_resource, :format => 'json')
end

Then /^I should be able to see the information about the route$/ do
  check_route_details_appear_in_the_api(@route)
end