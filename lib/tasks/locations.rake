require 'csv'
require 'nokogiri'
require 'open-uri'

SHAPEFILES = "lib/data/shapefiles"
ROADS = "lib/data/roads"

desc "Load location events"
task :load_events, [:file] => :environment do |t, args|
  file = args.file
  events = []
  puts "Loading location events from #{file}"
  CSV.foreach("lib/data/location/#{file}") do |row|
    events << Event.new(:unique_id => row[0], :road_id => row[1], :distance => row[2].to_f)
    if events.size % 1000 == 0
      Event.import events
      events = []
    end
  end
  Event.import events
end

desc "Download shapefiles from Minnesota Department of Transportation"
task :download_shapefiles do
  FileUtils.mkdir_p SHAPEFILES
  base_url = 'http://www.dot.state.mn.us/maps/gisbase'
  county_list = Nokogiri::HTML(open("#{base_url}/html/county_text.html"))
  county_list.xpath('//html/body/table[5]/tr[2]/td[2]/table/tr/td/a').each do |county_link|
    county = county_link['href'].match(/([a-z]*)\.html/)[1]
    if county == "lakewoods"
      county = "lakeofthewoods"
    elsif county == "stlouis"
      county = "saintlouis"
    end
    county_zip = "#{county}.zip"
    unless File.exists? "#{shapefiles}/#{county_zip}"
      File.open("#{shapefiles}/#{county_zip}",'wb') do |f|
        puts "Downloading #{county_zip}"
        f.write(open("#{base_url}/datafiles/county/#{county_zip}").read)
      end
    end
  end
end

desc "Generate roads SQL from downloaded Shapefiles"
task :generate_roads do
  FileUtils.mkdir_p SHAPEFILES
  FileUtils.mkdir_p ROADS
  Dir.foreach(SHAPEFILES) do |zipfile|
    unless ['.', '..'].include? zipfile
      base = File.basename zipfile, '.zip'
      FileUtils.mkdir_p "/tmp/#{base}"
      `unzip -d /tmp/#{base} #{File.join(SHAPEFILES, zipfile)}`
      puts "Generating roads SQL for #{base} county"
      `shp2pgsql -a -s 200000 -W UTF-8 /tmp/#{base}/*.shp roads > #{ROADS}/#{base}.sql`
      `rm -rf /tmp/#{base}`
    end
  end
end
