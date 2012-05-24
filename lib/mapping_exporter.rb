require 'router'

class MappingExporter

  attr_accessor :client, :done_tag, :endpoint_url, :logger

  def client
    @client ||= Router.new(endpoint_url, logger)
  end

  def endpoint_url
    @endpoint_url ||= "http://router.cluster:8080/router"
  end

  def done_tag
    @done_tag ||= "status:closed"
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def run
    @mappings = Mapping.tagged_with_all([ done_tag ])
    logger.info "#{@mappings.count} mappings loaded with the tag \"#{done_tag}\"..."

    @mappings.each do |mapping|
      path = URI.parse( mapping.old_url ).path
      client.create_redirect_route( path, "full", mapping.new_url )
      logger.info "     #{path} => #{mapping.new_url}"
    end

    logger.info "Export completed."
  end

end