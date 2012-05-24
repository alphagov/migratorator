require 'spec_helper'

describe MappingExporter do

  context "given the router client is mocked" do
    before do
      @mapping_exporter = MappingExporter.new
      @router_client = double()

      @mapping_exporter.client = @router_client
      @mapping_exporter.logger = NullLogger.instance
      @mapping_exporter.done_tag = "status:done"
    end

    context "given mappings exist" do
      before do
        @started_mappings = FactoryGirl.create_list(:mapping, 5, :tags => ["status:started"])
        @done_mappings = FactoryGirl.create_list(:mapping, 5, :tags => ["status:done"])
      end

      it "should add redirects into the router" do
        @done_mappings.each do |mapping|
          old_path = URI.parse( mapping.old_url ).path
          @router_client.should_receive(:create_redirect_route).with( old_path, "full", mapping.new_url )
        end

        @mapping_exporter.run
      end

      it "should not add not-done redirects into the router" do
        @started_mappings.each do |mapping|
          old_path = URI.parse( mapping.old_url ).path
          @router_client.should_not_receive(:create_redirect_route).with( old_path, "full", mapping.new_url )
        end

        @mapping_exporter.run
      end
    end
  end

end