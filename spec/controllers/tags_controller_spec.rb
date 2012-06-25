require 'spec_helper'

describe TagsController do

  before(:each) do
    login_as_stub_user
  end

  describe "retreiving all the tags" do
    before do
      Tag.create_from_string("section:education")
      Tag.create_from_string("top-level-tag")
    end

    describe "format HTML" do
      it "should assign tags" do
        get :index

        response.should be_success

        assigns(:tags).count.should == 2
        assigns(:tags).first.should be_instance_of(Tag)
      end
    end
  end

  describe "creating a tag" do
    describe "from a JSON POST request" do
      it "should create the tag" do
        post :create, tag: { whole_tag: "section:government" }, format: 'json'
        response.status.should == 201

        tag = Tag.find_by_string("section:government")

        tag.should be_instance_of(Tag)
        tag.group.should == "section"
        tag.name.should == "government"
      end

      it "should return a 201 Created status code" do
        post :create, tag: { whole_tag: "section:government" }, format: 'json'
        response.status.should == 201
      end
    end

    describe "from a HTTP POST request" do
      describe "given valid attributes" do
        it "should create the tag" do
          post :create, tag: { whole_tag: "section:government" }

          tag = Tag.find_by_string("section:government")
          tag.should be_instance_of(Tag)
          tag.group.should == "section"
          tag.name.should == "government"
        end

        it "should redirect to the tags index" do
          post :create, tag: { whole_tag: "section:government" }
          response.should be_redirect
        end
      end

      describe "given a blank tag" do
        it "should return the correct error" do
          post :create, tag: { whole_tag: "" }
          assigns(:tag).errors.messages.should have_key(:name)
        end
      end
    end
  end

  describe "updating a tag" do
    describe "from a JSON PUT request" do
      before do
        @tag = Tag.create_from_string("status:started")
      end

      describe "given valid attributes" do
        it "should rename the tag" do
          put :update, id: @tag, tag: { :whole_tag => "status:in-progress" }, format: 'json'
          response.status.should == 200

          old_tag = Tag.find_by_string("status:started")
          old_tag.should be_nil

          new_tag = Tag.find_by_string("status:in-progress")
          new_tag.should be_instance_of(Tag)

          new_tag.group.should == "status"
          new_tag.name.should == "in-progress"
        end
      end

      describe "given a blank tag" do
        it "should return the correct error" do
          put :update, id: @tag, tag: { :whole_tag => "" }, format: 'json'
          response.status.should == 422
        end
      end
    end

    describe "from a HTML PUT request" do
      before do
        @tag = Tag.create_from_string("status:started")
      end

      describe "given valid attributes" do
        it "should rename the tag" do
          put :update, id: @tag, tag: { :whole_tag => "status:in-progress" }
          response.status.should == 302

          old_tag = Tag.find_by_string("status:started")
          old_tag.should be_nil

          new_tag = Tag.find_by_string("status:in-progress")
          new_tag.should be_instance_of(Tag)

          new_tag.group.should == "status"
          new_tag.name.should == "in-progress"
        end
      end

      describe "given a blank tag" do
        it "should return the correct error" do
          put :update, id: @tag, tag: { :whole_tag => "" }
          assigns(:tag).errors.messages.should have_key(:name)
        end
      end
    end
  end

  describe "destroying a tag" do
    describe "from a JSON DELETE request" do
      before do
        @tag = Tag.create_from_string("beard:yes")
      end

      it "should destroy the tag" do
        delete :destroy, id: @tag, format: 'json'
        response.status.should == 200

        old_tag = Tag.find_by_string("beard:yes")
        old_tag.should be_nil
      end
    end
  end

end