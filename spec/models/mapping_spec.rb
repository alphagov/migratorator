require 'spec_helper'

describe Mapping do

  describe "retrieving a mapping" do
    before do
      @old_url = 'http://example.com/a_long_uri'
      Mapping.create! :old_url => @old_url, :new_url => 'http://new.com/test', :status => 301
    end

    it "should return a mapping object for a specified old url with the correct new url" do
      mapping = Mapping.find_by_old_url @old_url
      mapping.should be_an_instance_of Mapping
      mapping.new_url.should == 'http://new.com/test'
    end

    it "should raise an exception if no old url provided" do
      expect do
        Mapping.find_by_old_url ''
      end.to raise_error(Mapping::URLNotProvided)
    end

    it "should raise an exception if a mapping cannot be found" do
      expect do
        Mapping.find_by_old_url 'http://example.com/non_existent_url'
      end.to raise_error(Mapping::MappingNotFound)
    end
  end

  describe "creating a mapping" do
    before do
      @atts = {
        :title => "Example URL",
        :old_url => 'http://example.com/abc',
        :new_url => 'http://new.com/def',
        :status => 301,
        :tags => ["section:technology","format:nav"],
        :notes => "Ladies and gentlemen, an example has been reported in the building. Please wait for further instructions.",
        :search_query => "example",
        :related_items => [
          { :url => "http://related.com/xyz", :title => "Related Item #1" },
          { :url => "http://related.com/two", :title => "Related Item #2" }
        ]
      }
    end

    it "should create a mapping given valid attributes" do
      mapping = Mapping.create!(@atts)
      mapping.should be_an_instance_of Mapping
    end

    it "should throw an error if no old url present" do
      mapping = Mapping.new @atts.merge({:old_url => ''})
      mapping.should_not be_valid
    end

    it "should throw an error if status is redirect but no new url present" do
      mapping = Mapping.new @atts.merge({:status => 301, :new_url => ''})
      mapping.should_not be_valid
    end

    it "should throw an error if a mapping already exists for the specified old url" do
      existing_mapping = Mapping.create!(@atts)
      new_mapping = Mapping.new @atts

      new_mapping.should_not be_valid
    end
  end

end
