require 'spec_helper'

describe MappingsController do

  describe "when retrieving a mapping" do
    before do
      @mapping = Mapping.create! :title => "An example redirect", :old_url  => 'http://example.com/a_long_uri', :new_url => 'http://new.com/test', :status => 301, :tags_array => ["section:education", "type:article", "need-met:Y"], :notes => "A note string" 
      @json_representation = {
        "mapping" => {
          "id"           => @mapping.id,
          "title"         => "An example redirect",
          "old_url"       => @mapping.old_url,
          "status"        => 301, 
          "new_url"       => @mapping.new_url,
          "tags"          => ["section:education", "type:article", "need-met:Y"],
          "notes"         => "A note string",
          "search_query"  => nil,
          "related_links" => [ ]
        }
      }.to_json
    end

    it "should return a JSON object for a valid mapping" do
      get :show, old_url: @mapping.old_url, format: 'json'

      response.should be_success
      response.body.should == @json_representation
    end

    it "should return a 404 error for an invalid mapping" do
      get :show, old_url: "http://example.com/blah", format: 'json'

      response.status.should == 404
    end

    it "should return a 400 Bad Request error for an invalid mapping" do
      get :show

      response.status.should == 400
    end
  end

end
