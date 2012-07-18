require 'spec_helper'

describe Api::MappingController do

  before(:each) do
    login_as_stub_user
  end

  describe "JSON" do
    context "finding a mapping by old url" do

      before do
        @mapping = Mapping.create!( :title => "An example redirect", :old_url  => 'http://example.com/a_long_uri', :new_url => 'http://gov.uk/test', :status => 301, :tags => ["section:education", "article", "need-met:y"], :notes => "A note string")
        @json_representation = {
          "mapping" => {
            "id"           => @mapping.id.to_s,
            "title"         => "An example redirect",
            "old_url"       => @mapping.old_url,
            "status"        => 301,
            "new_url"       => @mapping.new_url,
            "notes"         => "A note string",
            "tags"          => ["section:education", "article", "need-met:y", "destination:content"]
          }
        }
      end

      it "should return a JSON object for a valid mapping" do
        get :index, old_url: @mapping.old_url, format: 'json'

        response.should be_success
        JSON.parse(response.body).should == @json_representation
      end
    end

  end

end
