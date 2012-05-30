class MappingIdentifier

  def filters
    [
      /%(20|23|27|284)/i,     # bad characters in urls
      /\.(gif|png|jpg)$/i,    # images
      /injected_by_wvs/i,     # pen testing urls
      /TB(a|c|d)/i,           # editor errors
      /n\/a/i,                #
      /Yet to be produced/i,  # parked
      /Not yet produced/i,    # parked
      /^$/,
    ]
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def run
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

end