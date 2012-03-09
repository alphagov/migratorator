require 'spec_helper'

describe Mapping do
  
  describe "retrieving a mapping" do
    before do
      @old_url = 'http://example.com/a_long_uri'
      Mapping.create! :old_url => @old_url, :new_url => 'http://new.com/test'
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

end
