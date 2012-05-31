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
  task :remove_inavlid_mappings => :environment do
    MappingIdentifier.new.purge_mappings_with_invalid_old_urls
  end

  desc "Process mappings with invalid new URLs"
  task :fix_new_urls => :environment do
    MappingIdentifier.new.fix_mappings_with_invalid_new_urls
  end
end