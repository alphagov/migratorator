namespace :migrator do

  task :import => :environment do
    json = JSON.parse( File.read(Rails.root.join('lib','data','import.json')) )['mappings']

    json.each do |mapping|
      begin
        puts "Create mapping for old URL #{mapping['old_url']}"
        Mapping.create! mapping
        puts "  Created"
      rescue Exception => e
        puts "  Error: #{e}"
      end
    end

  end

  desc "Identify invalid Old URLs in the database"
  task :identify => :environment do
    MappingIdentifier.new.identify
  end

  desc "Remove mappings with invalid old URLs"
  task :remove_invalid_mappings => :environment do
    MappingIdentifier.new.purge_mappings_with_invalid_old_urls
  end

  desc "Process mappings with invalid new URLs"
  task :fix_new_urls => :environment do
    MappingIdentifier.new.fix_mappings_with_invalid_new_urls
  end

  desc "Tag mappings with a content-item tag for the directgov ID"
  task :parse_directgov_urls => :environment do
    MappingIdentifier.new.parse_directgov_urls
  end

  desc "Find mappings with 'nav' name tag and append index.htm to it. Search Apache log created records for duplicates and remove them."
  task :clean_nav_mappings => :environment do
    nav_mappings = Mapping.tagged_with_all(['content-type:nav'])
    puts "Nav Mappings: #{nav_mappings.count}"
    apache_mappings = Mapping.tagged_with_all(['source:apache-logs'])
    puts "Apache Mappings: #{apache_mappings.count}"
    nav_mappings_old_urls = []
    nav_mappings_ids = []
    nav_mappings.each do |x| 
      nav_mappings_old_urls << x.old_url.strip.sub(/\/$/, '/index.htm')
      nav_mappings_ids << x.id
    end 
    puts "Nav Mappings Count: #{nav_mappings_old_urls.count}"
    puts "Nav Mappings Count after uniq: #{nav_mappings_old_urls.uniq.count}"
    duplicate_mappings = Mapping.any_in(old_url: nav_mappings_old_urls).not_in(_id: nav_mappings_ids)
    puts "Duplicate Mappings: #{duplicate_mappings.count}"
    puts "Deleting duplicates..."
    duplicate_mappings.destroy_all
    puts "Updating nav mappings..."
    invalid_count = 0
    nav_mappings.each do |x| 
      x.old_url = x.old_url.strip.sub(/\/$/, '/index.htm')
      if x.valid?
        x.save!
      else
        puts "InValid | #{x.old_url} | #{x.id}"
        invalid_count += 1
        old_mapping = Mapping.first(conditions: {old_url: /^#{x.old_url}$/i})
        old_mapping.destroy
        x.save!
        puts "Fixed: | #{x.old_url} | #{x.id}"
      end
    end 
    puts "Invalid count: #{invalid_count}"
    puts "Done!"
  end

end
