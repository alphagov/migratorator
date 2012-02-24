def api_response
  source
end

def check_route_details_appear_in_the_api(route)
  json = {
    :old_resource => route.old_resource,
    :new_resource => route.new_resource
  }.to_json

  api_response.should == json 
end