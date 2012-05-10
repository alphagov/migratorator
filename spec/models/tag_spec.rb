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

    it "should clean and downcase the tag" do
      tag_one = Tag.create_from_string("Section:CASE")
      tag_two = Tag.create_from_string("evil/slashes:test")
      tag_three = Tag.create_from_string("$@ME!-Oth^R-CH%rS")

      tag_one.whole_tag.should == "section:case"
      tag_two.whole_tag.should == "evil-slashes:test"
      tag_three.whole_tag.should == "me-oth-r-ch-rs"
    end

    it "should not create a duplicate tag on both group and name" do
      tag1 = Tag.create_from_string("section:example")
      tag2 = Tag.create_from_string("section:example")

      tag1.should be_persisted
      tag2.should_not be_persisted
      tag2.errors.size.should > 0
    end

    it "should allow creation of tags with duplicate names in different groups" do
      tag1 = Tag.create_from_string("section:example")
      tag2 = Tag.create_from_string("status:example")

      tag1.should be_persisted
      tag2.should be_persisted
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

  describe "renaming a tag" do
    it "should assign a name and group from a whole tag" do
      tag = Tag.create_from_string("music-taste:good")
      tag.whole_tag = "culinary-taste:bad"

      tag.group.should == "culinary-taste"
      tag.name.should == "bad"
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