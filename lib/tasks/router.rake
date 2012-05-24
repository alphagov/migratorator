require 'mapping_exporter'

namespace :router do

  task :export => :environment do
    MappingExporter.new.run
  end

end