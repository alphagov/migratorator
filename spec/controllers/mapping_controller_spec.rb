require 'spec_helper'

describe MappingsController do

  before(:each) do
    login_as_stub_user
  end

  describe "when listing all mappings" do
    it "finds the correct tag context" do
      Tag.create_from_string("section:example")
      Tag.create_from_string("status:done")
      Tag.create_from_string("proposition:citizen")

      get :index, :tags => 'section:example/status:done/proposition:citizen'

      assigns(:filter).should =~ ["section:example", "status:done", "proposition:citizen"]
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

          new_mapping.tags.size.should == 3 # automatic destination tag
          new_mapping.tags.map(&:whole_tag).should =~ ["section:education","article","destination:content"]
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
          attributes = { :title => "Test", :old_url => "http://foo.com/bar", :new_url => "http://gov.uk/foo", :status => 301 }
          post :create, mapping: attributes, format: 'html'

          Mapping.find_by_old_url("http://foo.com/bar").should be_instance_of Mapping
          response.should redirect_to(:action => :index)
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

  describe "when updating a mapping" do

    describe "from a html form" do
      describe "for a valid request" do
        before do
          @mapping = FactoryGirl.create(:mapping)
          @atts = { :title => "Test", :old_url => "http://new.com/foo", :new_url => "http://gov.uk/foo", :status => 301 }
        end

        it "should update the mapping and redirect to the index" do
          put :update, id: @mapping.id, mapping: @atts, format: 'html'

          Mapping.find_by_old_url("http://new.com/foo").should be_instance_of Mapping
          response.should redirect_to(:action => :index)
        end

        it "should create a history item attributed to the current user" do
          Mongoid::History.current_user_method = :current_user

          put :update, id: @mapping.id, mapping: @atts, format: 'html'

          mapping = Mapping.find_by_old_url("http://new.com/foo")

          mapping.history_tracks.size.should == 1
          mapping.history_tracks.first.modifier.should == @user

          Mongoid::History.current_user_method = :controller_name
        end

        it "can be marked as reviewed" do
          put :update, id: @mapping.id, mapping: @atts.merge(:reviewed => true), format: 'html'

          mapping = Mapping.find_by_old_url("http://new.com/foo")
          mapping.should be_reviewed
        end
      end
    end

  end

end





