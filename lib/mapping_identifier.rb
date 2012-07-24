class MappingIdentifier

  def filters
    [
      /%[A-Za-z0-9]+/i,     # bad characters in urls
      /%c0%af/,
      /\.(gif|png|jpg|js|css)$/i,    # non content resources
      /injected_by_wvs/i,     # pen testing urls
      /TB(a|c|d)$/i,           # editor errors
      /n\/a$/i,                #
      /Yet to be produced/i,  # parked
      /Not yet produced/i,    # parked
      /https?:\/\/.*http/i, # multiple urls in one string
      /\?CID/i, # query strings
      /^$/,
    ]
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def identify
    logger.info "Finding offending values for old_url...\n".colorize(:cyan)
    old_url_matches = Mapping.where(:old_url.in => filters).all
    logger.info "--> Found #{old_url_matches.count} bad urls".colorize(:cyan)
    old_url_matches.each do |mapping|
      logger.info "----> #{mapping.old_url} (#{mapping.title})"
    end

    logger.info "\n\nFinding offending values for new_url...\n".colorize(:cyan)
    new_url_matches = Mapping.where(:new_url.in => filters).all
    logger.info "--> Found #{new_url_matches.count} bad urls".colorize(:cyan)
    new_url_matches.each do |mapping|
      logger.info "----> #{mapping.new_url} (#{mapping.title})"
    end

    logger.info "\n\nChecking that all old urls belong to Directgov...\n".colorize(:cyan)
    non_dg_matches = Mapping.where(:old_url.nin => [ /^http:\/\/www\.direct\.gov\.uk/ ]).all
    logger.info "--> Found #{non_dg_matches.count} mappings with old urls not on Directgov".colorize(:cyan)
    non_dg_matches.each do |mapping|
      logger.info "----> #{mapping.old_url} (#{mapping.title})"
    end

    logger.info "\n\nChecking that all new urls point to GOV.UK...\n".colorize(:cyan)
    non_govuk_matches = Mapping.where(:new_url.nin => [ /^https?:\/\/www\.gov\.uk/ ], :status => 301).all
    logger.info "--> Found #{non_govuk_matches.count} mappings with new urls not on GOV.UK".colorize(:cyan)
    non_govuk_matches.each do |mapping|
      logger.info "----> #{mapping.new_url} (#{mapping.title})"
    end
  end

  def purge_mappings_with_invalid_old_urls
    logger.info "Finding offending values for old_url...\n".colorize(:cyan)
    old_url_matches = Mapping.where(:old_url.in => filters).all
    logger.info "--> Found #{old_url_matches.count} invalid mappings".colorize(:cyan)
    old_url_matches.each do |mapping|
      mapping.destroy
      logger.info "----> Deleted #{mapping.old_url}"
    end
  end

  def fix_mappings_with_invalid_new_urls
    logger.info "Finding offending values for new_url...\n".colorize(:cyan)
    new_url_matches = Mapping.where(:new_url.in => filters).all
    logger.info "--> Found #{new_url_matches.count} invalid mappings".colorize(:cyan)
    new_url_matches.each do |mapping|
      case mapping.new_url
      when /tb(a|b|c)/i, /n\/a$/i
        logger.info "----> Removing new_url from #{mapping.new_url} (#{mapping.title})"
        mapping.update_attributes!(:new_url => nil)
      when /Yet to be produced/i, /Not yet produced/i
        logger.info "----> Removing new_url from #{mapping.new_url} (#{mapping.title})"
        logger.info "----> Adding tag 'status:pending-content' to #{mapping.new_url} (#{mapping.title})"

        mapping.new_url = nil
        mapping.tags = mapping.tags.reject {|t| t.group == "status"} + ["status:pending-content"]
        mapping.save!
      when /^$/
        logger.info "----> Removing new_url from #{mapping.new_url} (#{mapping.title})"
        mapping.update_attributes!(:new_url => nil)
      end
    end
  end

  def parse_directgov_urls
    logger.info "Loading all mappings..."
    mappings = Mapping.tagged_with_all(["site:directgov"]).each do |mapping|
      dg_id = case mapping.old_url
      when /dg_([A-Za-z0-9_]+)(\.[a-z0-9]{3,4})?$/i then "dg-content-#{$1}".downcase.gsub('_','-')
      when /(en|cy)\/([A-Za-z0-9-_\/]+)\/(index\.htm)?/ then "dg-section-#{$2}".downcase.gsub('/','-')
      else
        nil
      end

      unless dg_id.blank?
        mapping.tags = mapping.tags.reject {|t| t.group == "content-item"} + ["content-item:#{dg_id}"]
        mapping.save!
        puts "#{dg_id} ----> #{mapping.old_url.sub('http://www.direct.gov.uk','')}"
      else
        puts "No dg id for #{mapping.old_url}".colorize(:red) if dg_id.blank?
      end

    end
  end

end
