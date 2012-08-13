require 'csv'

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

  desc "Create Business Link Mappings"
  task :create_bl_mappings, [:file] => :environment do |t, args|
    
    puts "starting url mapping rake task"
    
    rows = CSV.read(args[:file])
    
    puts "processing  #{rows.length} mappings"

    mappings = 0
    errmps = []
    existsurl = []
    
    rows.each_with_index do |r,i|
      unless r[2].blank? #or r[0].blank? #r[3].blank? or 
          
        old = r[2]
        if Mapping.exists?(conditions: {old_url: old}) 
          existsurl << [i,r].join(',')
          puts "#{i}: URL EXISTS"
          next
        end
        Mapping.create(:old_url => old) do |m|
          begin
          title = r[0] 

          m.title = r[0] unless r[0].blank?
          m.old_url = old
          
          unless r[3].blank? or not r[3].include?('gov.uk')

            m.new_url = r[3].match(/^https?:\/\//) ? r[3] : "http://" + r[3]
          end
          m.tags_list =  "canonical:true, site:businesslink" 
           
          puts "#{i}: created #{title}"
          mappings += 1
          rescue Mongoid::Error
            errmps << [i,r].join(',')
            msg = "#{i}: ERROR ["
            msg += "Mapping create error;" 
            msg += "]"  
            puts msg
            next
          end  
        end
      else
        errmps << [i,r].join(',')
        msg = "#{i}: ERROR ["
        msg += "old url blank;" if r[2].blank?
        msg += "]"
        puts msg
      end

    end

    
    # write all errors to file
    fnerr = "bl_mapping_errors_"+ Time.now.strftime("%Y%m%d%H%M%S") +".csv"
    File.open(fnerr, 'w') {|f| f.write(errmps.join("\n")) }

    # write all duplicate urls found
    fnex = "bl_mapping_exists_"+ Time.now.strftime("%Y%m%d%H%M%S") +".csv"
    File.open(fnex, 'w') {|f| f.write(existsurl.join("\n")) }

    puts "You just had :" 
    puts "\t" + mappings.to_s + " mapping created"
    puts "\t" + errmps.length.to_s + " errors"
    puts "\t" + existsurl.length.to_s + " URLs that existed"
    puts "\t" + rows.length.to_s + " mappings processed"


    puts "rake tast completed"
  end

  desc "Get a CSV output of mappings from DB"
  task :output_mappings_to_csv, [:tag] => :environment do |t, args|
    tag = args[:tag]
    puts tag
    csv = CSV.generate do |csv|
      csv << ["Title", "Old Url", "New Url", "Status", "Notes", "Group", "Name", "Whole Tag"]
      Mapping.where(:tags_cache.in => [tag]).each do |mapping|
        tag_group = []
        tag_name = []
        tag_whole_tag = []
        mapping.tags.each do |tag|
          tag_group << tag.group
          tag_name << tag.name
          tag_whole_tag << tag.whole_tag
        end
        print '.'
        csv << [mapping.title, mapping.old_url, mapping.new_url, mapping.status, mapping.notes, tag_group.join(' '), tag_name.join(' '), tag_whole_tag.join(' ')]
      end
    end
    fn = "bl_mapping_output_"+ Time.now.strftime("%Y%m%d%H%M%S") +".csv"
    File.open(fn, 'w') {|f| f.write(csv) }

  end


end
