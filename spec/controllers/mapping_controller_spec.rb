require 'spec_helper'

describe MappingsController do

  describe "when listing all mappings" do
    it "finds the correct tag context" do
      Tag.create_from_string("section:example")
      Tag.create_from_string("status:done")
      Tag.create_from_string("proposition:citizen")

      get :index, :tags => 'section:example/status:done/proposition:citizen'

      assigns(:tags_filter).should =~ ["section:example", "status:done", "proposition:citizen"]
    end

    it "retrieves the correct progress percentage for a given tag" do
      @tag_one = FactoryGirl.create(:mapping, :tags => ["section:example","status:done"])
      @tag_two = FactoryGirl.create(:mapping, :tags => ["section:example","status:bin"])
      @tag_three = FactoryGirl.create(:mapping, :tags => ["section:something-else","status:done"])
      @tag_four = FactoryGirl.create(:mapping, :tags => [])

      Tag.create_from_string("empty_tag")

      get :index, :progress => 'status:done'
      assigns(:progress).percentage.should == 50
      assigns(:progress).tag.should == 'status:done'
      assigns(:progress).total.should == 4

      get :index, :progress => 'status:done', :tags => "section:example"
      assigns(:progress).percentage.should == 50
      assigns(:progress).count.should == 1
      assigns(:progress).total.should == 2

      get :index, :progress => 'status:done', :tags => "section:example/status:done"
      assigns(:progress).percentage.should == 100
      assigns(:progress).total.should == 1

      get :index, :progress => 'status:done', :tags => "empty_tag"
      assigns(:progress).percentage.should == 0
      assigns(:progress).total.should == 0
    end
  end

  describe "when retrieving a mapping" do
    describe "JSON" do
      before do
        @mapping = Mapping.create! :title => "An example redirect", :old_url  => 'http://example.com/a_long_uri', :new_url => 'http://new.com/test', :status => 301, :tags => ["section:education", "article", "need-met:y"], :notes => "A note string"
        @json_representation = {
          "mapping" => {
            "id"           => @mapping.id,
            "title"         => "An example redirect",
            "old_url"       => @mapping.old_url,
            "status"        => 301,
            "new_url"       => @mapping.new_url,
            "notes"         => "A note string",
            "search_query"  => nil,
            "tags"          => ["article", "need-met:y", "section:education"],
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
      before do
        request.env['CONTENT_TYPE'] = 'application/json'
      end

      describe "for a valid request" do
        before do
          @atts = {
            new_url: "https://www.gov.uk/your-consumer-rights/buying-a-car",
            old_url: "http://www.direct.gov.uk/en/Governmentcitizensandrights/Consumerrights/Buyingacar-yourconsumerrights/DG_183043",
            status: "301",
            tags: [
                "section:education",
                "article"
            ],
            title: "Repairing and servicing your car : Directgov - Government, citizens and rights"
          }
        end

        it "should create the mapping in the database" do
          post :create, :mapping => @atts, :format => 'json'

          new_mapping = Mapping.find_by_old_url "http://www.direct.gov.uk/en/Governmentcitizensandrights/Consumerrights/Buyingacar-yourconsumerrights/DG_183043"

          new_mapping.should be_instance_of Mapping
          new_mapping.new_url.should == "https://www.gov.uk/your-consumer-rights/buying-a-car"
          new_mapping.status.should == 301

          new_mapping.tags.size.should == 2
          new_mapping.tags.map(&:marshal_dump).should =~ [{:group => "section", :name => "education", :whole_tag => "section:education"},{:group => nil, :name => "article", :whole_tag => "article"}]
        end

        it "should return a 201 Created status code" do
          post :create, mapping: @atts, format: 'json'

          response.status.should == 201
        end
      end

      describe "for an invalid request" do
        before do
          @atts = {
            new_url: "https://www.gov.uk/your-consumer-rights/buying-a-car",
            status: "301"
          }
        end

        it "should not create the mapping in the database" do
          post :create, mapping: @atts, format: 'json'

          expect do
            Mapping.find_by_old_url "http://www.direct.gov.uk/en/Governmentcitizensandrights/Consumerrights/Buyingacar-yourconsumerrights/DG_183043"
          end.to raise_error(Mapping::MappingNotFound)
        end

        it "should return a 422 Unprocessable Entity status code" do
          post :create, mapping: @atts, format: 'json'

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





