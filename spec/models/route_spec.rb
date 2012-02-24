require 'spec_helper'

describe Route do
  
  describe "retrieving a route" do
    before do
      @old_resource = 'http://example.com/a_long_uri'
      Route.create! :old_resource => @old_resource, :new_resource => 'http://new.com/test'
    end

    it "should return a route object for a specified old resource with the correct new resource" do
      route = Route.find_by_old_resource @old_resource
      route.should be_an_instance_of Route
      route.new_resource.should == 'http://new.com/test'
    end

    it "should raise an exception if a route cannot be found" do
      expect do
        Route.find_by_old_resource 'http://example.com/non_existent_url'
      end.to raise_error(Route::RouteNotFound)
    end
  end

end
