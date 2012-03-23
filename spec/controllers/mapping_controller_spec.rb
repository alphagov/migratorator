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


  describe "when creating a mapping from a single JSON object" do
    describe "for a valid request" do
      before do
        @json = %q{
          {
            "new_url": "https://www.gov.uk/your-consumer-rights/buying-a-car",
            "old_url": "http://www.direct.gov.uk/en/Governmentcitizensandrights/Consumerrights/Buyingacar-yourconsumerrights/DG_183043",
            "status": "301",
            "tags": [
                "section: Government, citizens and rights",
                "article"
            ],
            "title": "Repairing and servicing your car : Directgov - Government, citizens and rights"
          }
        }
      end

      it "should create the mapping in the database" do
        post :create, json: @json, format: 'json'

        new_mapping = Mapping.find_by_old_url "http://www.direct.gov.uk/en/Governmentcitizensandrights/Consumerrights/Buyingacar-yourconsumerrights/DG_183043"

        new_mapping.should be_instance_of Mapping
        new_mapping.new_url.should == "https://www.gov.uk/your-consumer-rights/buying-a-car"
        new_mapping.status.should == 301
        new_mapping.tags.should == ["section: Government, citizens and rights","article"]
      end

      it "should return a 201 Created status code" do
        post :create, json: @json, format: 'json'

        response.status.should == 201
      end
    end
  end

end





