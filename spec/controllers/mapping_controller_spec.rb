require 'spec_helper'

describe MappingsController do

  describe "when retrieving a mapping" do
    describe "JSON" do
      before do
        @mapping = Mapping.create! :title => "An example redirect", :old_url  => 'http://example.com/a_long_uri', :new_url => 'http://new.com/test', :status => 301, :tags_array => ["section:education", "article", "need-met:Y"], :notes => "A note string"
        @json_representation = {
          "mapping" => {
            "id"           => @mapping.id,
            "title"         => "An example redirect",
            "old_url"       => @mapping.old_url,
            "status"        => 301,
            "new_url"       => @mapping.new_url,
            "tags"          => [{:type => "section", :name => "education"},{:type => nil, :name => "article"},{:type => "need-met", :name => "y"}],
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


  describe "when creating a mapping" do

    describe "from a single JSON object" do
      describe "for a valid request" do
        before do
          @json = %q{
            {
              "new_url": "https://www.gov.uk/your-consumer-rights/buying-a-car",
              "old_url": "http://www.direct.gov.uk/en/Governmentcitizensandrights/Consumerrights/Buyingacar-yourconsumerrights/DG_183043",
              "status": "301",
              "tags": [
                  "section:education",
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
          new_mapping.tags.should == [{:type => "section", :name => "education"},{:type => nil, :name => "article"}]
        end

        it "should return a 201 Created status code" do
          post :create, json: @json, format: 'json'

          response.status.should == 201
        end
      end

      describe "for an invalid request" do
        before do
          @json = %q{
            {
              "new_url": "https://www.gov.uk/your-consumer-rights/buying-a-car",
              "status": "301"
            }
          }
        end

        it "should not create the mapping in the database" do
          post :create, json: @json, format: 'json'

          expect do
            Mapping.find_by_old_url "http://www.direct.gov.uk/en/Governmentcitizensandrights/Consumerrights/Buyingacar-yourconsumerrights/DG_183043"
          end.to raise_error(Mapping::MappingNotFound)
        end

        it "should return a 422 Unprocessable Entity status code" do
          post :create, json: @json, format: 'json'

          response.status.should == 422
        end
      end
    end

    describe "from a html form" do

      describe "for a valid request" do
        it "should create the mapping and redirect to the index" do
          attributes = { :title => "Test", :old_url => "http://foo.com/bar", :new_url => "http://bar.com/foo", :status => 301 }
          post :create, mapping: attributes, format: 'html'

          Mapping.find_by_old_url("http://foo.com/bar").should be_instance_of Mapping
          response.should redirect_to(:action => :index)
        end

        it "should save related items" do
          attributes = { :title => "Test", :old_url => "http://foo.com/bar", :status => 410, :related_links => [ { :url => "http://foo.com/related", :title => "Test" }, { :url => "http://foo.com/something", :title => "Another Test"} ] }
          post :create, mapping: attributes, format: 'html'

          mapping = Mapping.find_by_old_url("http://foo.com/bar")
          mapping.should be_instance_of Mapping
          mapping.related_links.size.should == 2
          mapping.related_links.first.should be_instance_of RelatedLink
        end
      end

      describe "without an old url" do
        it "should not create a mapping" do
          attributes = { :title => "Test" }
          post :create, mapping: attributes, format: 'html'

          response.should render_template(:new)
          response.should_not redirect_to(:action => :index)
        end
      end

    end

  end

end





