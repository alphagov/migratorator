require 'spec_helper'

describe TagsController do

  describe "retreiving all the tags" do
    before do
      Tag.create_from_string("section:education")
      Tag.create_from_string("top-level-tag")
    end

    describe "format JSON" do
      it "should return an array of tags" do
        get :index, format: 'json'

        response.should be_success
        JSON::parse(response.body).should =~ [
          { "tag" => { "group" => "section", "name" => "education", "whole_tag" => "section:education"} },
          { "tag" => { "group" => nil, "name" => "top-level-tag", "whole_tag" => "top-level-tag"} }
        ]
      end
    end
  end

  describe "creating a tag" do
    describe "from a JSON POST request" do
      before do
        @json = %q{
          {
            "tag" : "section:government"
          }
        }
      end

      it "should create the tag" do
        post :create, json: @json, format: 'json'
        response.status.should == 201

        tag = Tag.find_by_string("section:government")

        tag.should be_instance_of(Tag)
        tag.group.should == "section"
        tag.name.should == "government"
      end
    end
  end

end