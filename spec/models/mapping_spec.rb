require 'spec_helper'

describe Mapping do

  describe "retrieving mappings by tag" do
    before do
      @tag_one = FactoryGirl.create(:mapping, :tags => ["section:example","status:done"])
      @tag_two = FactoryGirl.create(:mapping, :tags => ["section:example","status:bin"])
      @tag_three = FactoryGirl.create(:mapping, :tags => ["section:something-else","status:done"])
    end

    def tagged_with(tags)
      Mapping.tagged_with_all(tags)
    end

    def tagged_with_collection(tags)
      tagged_with(tags).all.to_a
    end

    it "should return the correct mappings" do
      tagged_with_collection(["section:example"]).should =~ [@tag_one, @tag_two]
      tagged_with_collection(["status:done"]).should =~ [@tag_one, @tag_three]
      tagged_with_collection(["section:example","status:bin"]).should =~ [@tag_two]
      tagged_with_collection(["section:example","status:done"]).should =~ [@tag_one]
      tagged_with_collection(["section:something-else","status:bin"]).should =~ []
    end

    it "should calculate the progress percentage" do
      Mapping.progress(Mapping.tagged_with_all(["section:example"]),"status:done").percentage.should == 50
      Mapping.progress(Mapping.tagged_with_all(["section:example"]),"status:done").count.should == 1
    end
  end

  describe "searching for a mapping by old_url" do
    before do
      @mapping_one = FactoryGirl.create(:mapping, :old_url => "http://example.com/one", :tags => ["status:done"])
      @mapping_two = FactoryGirl.create(:mapping, :old_url => "http://example.com/two", :tags => ["status:bin"])
      @mapping_three = FactoryGirl.create(:mapping, :old_url => "http://test.com/three", :tags => ["status:done"])
    end

    it "should calculate the progress percentage" do
      Mapping.progress(Mapping.by_old_url("example"),"status:done").percentage.should == 50
      Mapping.progress(Mapping.by_old_url("example"),"status:done").count.should == 1
    end

    it "should return the correct mappings for a search" do
      Mapping.by_old_url("example.com").all.to_a.should =~ [@mapping_one, @mapping_two]
      Mapping.by_old_url("test.com").all.to_a.should =~ [@mapping_three]
    end
  end

  describe "retrieving a mapping" do
    before do
      @old_url = 'http://example.com/a_long_uri'
      Mapping.create! :old_url => @old_url, :new_url => 'http://www.gov.uk/new_url', :status => 301
    end

    it "should return a mapping object for a specified old url with the correct new url" do
      mapping = Mapping.find_by_old_url @old_url
      mapping.should be_an_instance_of Mapping
      mapping.new_url.should == 'http://www.gov.uk/new_url'
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

    it "should find a mapping's tag given the group" do
      mapping = FactoryGirl.create(:mapping, :tags => ["status:open","section:home"])
      mapping.tag_for('status').should == "open"
      mapping.tag_for('section').should == "home"
    end
  end

  describe "creating a mapping" do
    before do
      @atts = {
        :title => "Example URL",
        :old_url => 'http://example.com/abc',
        :new_url => 'http://www.gov.uk/new_url',
        :status => 301,
        :tags => ["section:technology","format:nav"],
        :notes => "Ladies and gentlemen, an example has been reported in the building. Please wait for further instructions."
      }
      @atts2 = {
        :title => "Example URL",
        :old_url => 'http://example.com/ABC',
        :new_url => 'http://www.gov.uk/new_url',
        :status => 301,
        :tags => ["section:technology","format:nav"],
        :notes => "Ladies and gentlemen, an example has been reported in the building. Please wait for further instructions."
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

    it "should throw an error if old url is not a valid url" do
      mapping = Mapping.new @atts.merge({:old_url => 'www.direct.gov.uk'})
      mapping.should_not be_valid
    end

    it "should throw an error if old url contains spaces" do
      mapping = Mapping.new @atts.merge({:old_url => 'http://www.direct.gov.uk '})
      mapping.should_not be_valid
    end

    it "should throw an error if old url includes valid url but is not valid url" do
      mapping = Mapping.new @atts.merge({:old_url => 'maps from http://www.direct.gov.uk'})
      mapping.should_not be_valid
    end

    it "should throw an error if the national archive url is not a valid url" do
      mapping = Mapping.new @atts.merge({:archive_url => 'www.tna.gov.uk'})
      mapping.should_not be_valid
    end

    it "should throw an error if the national archives url includes valid url but is not valid url" do
      mapping = Mapping.new @atts.merge({:archive_url => 'archive url is http://webarchive.nationalarchives.gov.uk/20121015000000/www.direct.gov.uk/en/Parents/Yourchildshealthandsafety/Yourchildssafetyinthehome/index.htm'})
      mapping.should_not be_valid
    end

    it "should not throw an error if the national archives url is a valid url" do
      mapping = Mapping.new @atts.merge({:archive_url => 'http://webarchive.nationalarchives.gov.uk/20121015000000/www.direct.gov.uk/en/Parents/Yourchildshealthandsafety/Yourchildssafetyinthehome/index.htm'})
      mapping.should be_valid
    end

    it "should throw an error if status is redirect but new url is not a valid url" do
      mapping = Mapping.new @atts.merge({:status => 301, :new_url => "n/a tbc this isnt a url"})
      mapping.should_not be_valid
    end

    it "should throw an error if status is redirect but new url includes a valid url but is not a valid url" do
      mapping = Mapping.new @atts.merge({:status => 301, :new_url => "maps to https://www.gov.uk"})
      mapping.should_not be_valid
    end

    it "should throw an error if status is redirect but new url includes spaces" do
      mapping = Mapping.new @atts.merge({:status => 301, :new_url => " https://www.gov.uk"})
      mapping.should_not be_valid
    end

    it "should throw an error if a mapping already exists for the specified old url" do
      existing_mapping = Mapping.create!(@atts)
      new_mapping = Mapping.new @atts

      new_mapping.should_not be_valid
    end

    it "should throw an error if a mapping already exists for the specified old url and the case is different" do
      existing_mapping = Mapping.create!(@atts)
      new_mapping = Mapping.new @atts2

      new_mapping.should_not be_valid
    end

    it "should throw an error if a mapping has two tags from the same group" do
      mapping = Mapping.new @atts.merge({:tags => ["section:one", "section:two"]})
      mapping.should_not be_valid
    end

    it "should allow a mapping to have multiple tags without groups" do
      mapping = Mapping.new @atts.merge({:tags => ["biscuits", "milk"]})
      mapping.should be_valid
    end

    it "should parse tags for a mapping" do
      mapping = Mapping.new(@atts)
      mapping.tags_list = "section:example,format:nav"
      mapping.save!

      mapping.tags.size.should == 3 # including automatic destination tag
      mapping.tags.first.should be_respond_to(:whole_tag)
    end
  end

  describe "manipulating tags on a mapping" do
    it "should remove a tag" do
      @mapping = FactoryGirl.create(:mapping, :tags => ["tag_one","tag_two","tag_three","tag_four"])

      @mapping.tags_list = "tag_one,tag_two,tag_four,destination:content"
      @mapping.save!
      @mapping.reload

      @mapping.tags.count.should == 4 # including automatic destination tag
      @mapping.tags.map(&:whole_tag).should =~ ["tag_one", "tag_two", "tag_four", "destination:content"]
    end

    it "should save tags from the tags list" do
      @mapping = FactoryGirl.create(:mapping, :tags => ["tag_one", "tag_two"])
      @mapping.tags_list.should == "tag_one, tag_two, destination:content" # including automatic destination tag

      @mapping.tags_list = "tag_one, tag_two, tag_three"
      @mapping.save!
      @mapping.reload

      @mapping.tags.map(&:whole_tag).should =~ ["tag_one", "tag_two", "tag_three", "destination:content"] # including automatic destination tag
    end
  end

  describe "making changes to a mapping" do
    context "given valid changes" do
      it "should create a history item" do
        @mapping = FactoryGirl.create(:mapping)
        @mapping.new_url = 'https://www.gov.uk/an-updated-url'
        @mapping.save!

        @mapping.history_tracks.size.should == 1
        @mapping.history_tracks.first.affected.should == { "new_url" => 'https://www.gov.uk/an-updated-url' }
      end

      it "should create a history item for changes in tags" do
        @mapping = FactoryGirl.create(:mapping, :tags => ["tag-one","tag-two","tag-three"])
        @mapping.tags_list = "tag-four,tag-five"
        @mapping.save!
        @mapping.reload

        @mapping.history_tracks.first.affected.should == { "tags_list_cache" => 'tag-four, tag-five, destination:content' } # including automatic destination tag
      end
    end

    context "given a mapping which has not been reviewed" do
      before do
        @mapping = FactoryGirl.create(:mapping, :tags => ["reviewed:no","status:open"])
      end

      it "should add a reviewed:yes tag when marked as reviewed" do
        @mapping.reviewed = true
        @mapping.tag_for('reviewed').should == "yes"
      end

      it "should not remove existing tags" do
        @mapping.reviewed = true
        @mapping.tag_for('status').should == "open"
      end
    end

    context "given a mapping which has been reviewed" do
      before do
        @mapping = FactoryGirl.create(:mapping, :tags => ["reviewed:yes","status:open"])
      end

      it "should be marked as reviewed" do
        @mapping.reload
        @mapping.should be_reviewed
      end

      it "should have a reviewed:no tag when marked as not reviewed" do
        @mapping.reviewed = false

        @mapping.tag_for('reviewed').should == "no"
        @mapping.should_not be_reviewed
      end
    end
  end

end
