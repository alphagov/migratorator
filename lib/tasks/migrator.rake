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
    
    # use the bl_mappings_v2.csv found in the db dir 
    unless args[:file]
      puts "Please specify a csv to import (hint: check the db dir and/or the commments in this rake task)"
      exit
    end

    rows = CSV.read(args[:file])
    
    puts "processing  #{rows.length} mappings"

    mappings = 0
    errmps = []
    existsurl = []
    
    old = ''
    
    batch = []

    # create tags
    puts "get tags"

    tags_a = []
    tag_source = Tag.find_or_create_by(group: 'site', name: 'businesslink')
    tag_canonical = Tag.find_or_create_by(group: 'canonical', name: 'true')
    tags_a << tag_source.id
    tags_a << tag_canonical.id

    puts "got tags"


    # rows[0..999].each_with_index do |r,i| # DEBUG: run with a range on rows if desired for debug
    rows.each_with_index do |r,i|
      

      unless r[2].blank? #or r[0].blank? #r[3].blank? or 
        
        old = r[2]
        
        if Mapping.exists?(conditions: {old_url: old}) 
          existsurl << [i,r].join(',')
          puts "#{i}: URL EXISTS"
          next
        end

        title = ''
        title = r[0] unless r[0].blank?
        newurl = ''
        unless r[3].blank? or not r[3].include?('gov.uk')
          newurl = r[3].match(/^https?:\/\//) ? r[3] : "http://" + r[3]
        end
        tags_list =  ["canonical:true", "site:businesslink"]


        batch << {
          :old_url => old,
          :title => title,
          :new_url => newurl,
          :tags_cache => tags_list,
          :tagged_with_ids => tags_a,
          :tags_list_cache => tags_list.join(',') 
        }



        # mappings += 1

        puts "#{i} lines processed" if i % 1000 == 0 

      else
        errmps << [i,r].join(',')
        msg = "#{i}: ERROR ["
        msg += "old url blank;" if r[2].blank?
        msg += "]"
        puts msg
      end

    end


    # p batch  
    puts "inserting #{batch.length} docs"
    
    # NOTE: this allows you to insert an array of hashes (one for each document)
    # However, it doesn't run any validations so you must do those before populating the array
    mps = Mapping.collection.insert(batch)
    puts "docs inserted; updating tags with doc ids"

    tag_canonical.mapping_ids += mps
    tag_canonical.save
    tag_source.mapping_ids += mps
    tag_source.save

    puts "tags updated; creating output files (if needed) for duplicates urls and errors"


    # write all errors to file
    fnerr = "bl_mapping_errors_"+ Time.now.strftime("%Y%m%d%H%M%S") +".csv"
    File.open(fnerr, 'w') {|f| f.write(errmps.join("\n")) } if errmps.length > 0

    # write all duplicate urls found
    fnex = "bl_mapping_exists_"+ Time.now.strftime("%Y%m%d%H%M%S") +".csv"
    File.open(fnex, 'w') {|f| f.write(existsurl.join("\n")) } if existsurl.length > 0


    puts "You just had :" 
    puts "\t" + batch.length.to_s + " mapping created"
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
