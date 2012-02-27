require 'spec_helper'

describe RoutesController do

  describe "when retrieving a route" do
    before do
      @route = Route.create! :old_resource => 'http://example.com/a_long_uri', :new_resource => 'http://new.com/test'
    end

    it "should return a JSON object for a valid route" do
      get :show, old_resource: @route.old_resource, format: 'json'

      response.should be_success
      response.body.should == { old_resource: @route.old_resource, new_resource: @route.new_resource }.to_json
    end

    it "should return a 404 error for an invalid route" do
      get :show, old_resource: "http://example.com/blah", format: 'json'

      response.status.should == 404
    end

    it "should return a 400 Bad Request error for an invalid route" do
      get :show

      response.status.should == 400
    end
  end

end
