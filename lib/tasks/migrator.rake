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

end