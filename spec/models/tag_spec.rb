require 'spec_helper'

describe Tag do

  describe "creating a tag" do
    it "should create a tag from a string" do
      tag = Tag.create_from_string("section:example")

      tag.should be_instance_of(Tag)
      tag.should be_persisted

      tag.group.should == "section"
      tag.name.should  == "example"
    end

    it "should downcase the tag" do
      tag = Tag.create_from_string("Section:CASE")

      tag.group.should == "section"
      tag.name.should  == "case"
    end
  end

  describe "retreiving a tag" do
    it "should return a tag from a string" do
      Tag.create_from_string("section:example")

      tag = Tag.find_by_string("section:example")
      tag.should be_instance_of(Tag)

      tag.group.should == "section"
      tag.name.should  == "example"
    end

    it "should return a tag from a hash" do
      Tag.create_from_string("section:example")

      tag = Tag.find_by_group_and_name("section","example")
      tag.should be_instance_of(Tag)

      tag.group.should == "section"
      tag.name.should == "example"
    end

    it "should return a whole tag of multiple parts" do
      tag = Tag.create_from_string("section:example")

      tag.whole_tag.should == "section:example"
    end
  end

  describe "retreiving a group" do
    it "should return a collection of tags when given a group" do
      Tag.create_from_string("section:government")
      Tag.create_from_string("section:education")
      Tag.create_from_string("section:driving")

      tags = Tag.find_by_group("section")
      tags.size.should == 3
      tags.each {|tag| tag.should be_instance_of(Tag) }
    end
  end

end