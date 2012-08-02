require_relative '../../spec_helper'

describe Api::MappingsController do

  before(:each) do
    login_as_stub_user
  end

  describe "JSON" do
    context "finding a mapping by old url" do

      before do
        @mapping = Mapping.create! :title => "An example redirect", :old_url  => 'http://example.com/a_long_uri', :new_url => 'http://gov.uk/test', :status => 301, :tags => ["section:education", "article", "need-met:y"], :notes => "A note string"
        @json_representation = [{
          "mapping" => {
            "id"           => @mapping.id.to_s,
            "title"         => "An example redirect",
            "old_url"       => @mapping.old_url,
            "status"        => 301,
            "new_url"       => @mapping.new_url,
            "notes"         => "A note string",
            "tags"          => ["section:education", "article", "need-met:y", "destination:content"]
          }
        }]
      end

      it "should return a JSON object for a valid mapping" do
        get :index, old_url: @mapping.old_url, format: 'json'

        response.should be_success
        JSON.parse(response.body)["mappings"].should == @json_representation
      end
    end

    context "retrieving a single mapping" do
      it "should return a 404 error for an invalid mapping" do
        get :show, id: "not-a-real-id", format: 'json'
        response.status.should == 404
      end
    end

    context "retrieving a group of mappings" do
      it "should return a list of mappings when passed a hash of ids" do

        old_url_1 = 'http://example.com/1'
        old_url_2 = 'http://example.com/2'
        old_url_3 = 'http://example.com/3'
        
        mapping_1 = Mapping.create! :old_url  => old_url_1, :status => 301
        mapping_2 = Mapping.create! :old_url  => old_url_2, :status => 301
        mapping_3 = Mapping.create! :old_url  => old_url_3, :status => 301
        
        @json_representation = {
          mapping_1.id.to_s => {
            "id"            => mapping_1.id.to_s,
            "title"         => nil,
            "old_url"       => old_url_1,
            "status"        => 301,
            "new_url"       => nil
          },
            mapping_2.id.to_s =>
          {
              "id"            => mapping_2.id.to_s,
              "title"         => nil,
              "old_url"       => old_url_2,
              "status"        => 301,
              "new_url"       => nil
          },
            mapping_3.id.to_s =>
          {
              "id"            => mapping_3.id.to_s,
              "title"         => nil,
              "old_url"       => old_url_3,
              "status"        => 301,
              "new_url"       => nil
          }
        }

        get :by_id_array, id_array: "#{mapping_1.id},#{mapping_2.id},#{mapping_3.id}", format: 'json'
        
        response.should be_success

        JSON.parse(response.body).should == @json_representation
      end
    end

    context "retrieving a group of mappings by old_url" do
      it "should return a list of mappings when passed a hash of old_urls" do

        old_url_1 = 'http://example.com/1'
        old_url_2 = 'http://example.com/2'
        old_url_3 = 'http://example.com/3'
        
        mapping_1 = Mapping.create! :old_url  => old_url_1, :status => 301
        mapping_2 = Mapping.create! :old_url  => old_url_2, :status => 301
        mapping_3 = Mapping.create! :old_url  => old_url_3, :status => 301
        
        @json_representation = {
          old_url_1 => {
            "id"            => mapping_1.id.to_s,
            "title"         => nil,
            "old_url"       => old_url_1,
            "status"        => 301,
            "new_url"       => nil
          },
            old_url_2 =>
          {
              "id"            => mapping_2.id.to_s,
              "title"         => nil,
              "old_url"       => old_url_2,
              "status"        => 301,
              "new_url"       => nil
          },
            old_url_3 =>
          {
              "id"            => mapping_3.id.to_s,
              "title"         => nil,
              "old_url"       => old_url_3,
              "status"        => 301,
              "new_url"       => nil
          }
        }

        get :by_old_url_array, old_url_array: "#{old_url_1},#{old_url_2},#{old_url_3}", format: 'json'
        
        response.should be_success

        JSON.parse(response.body).should == @json_representation
      end
    end
  end

end