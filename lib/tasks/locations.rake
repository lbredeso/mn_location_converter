require 'csv'
require 'nokogiri'
require 'open-uri'

BASE_URL = 'http://www.dot.state.mn.us/maps/gisbase'
BATCH_SIZE = 1000
ROADS = "lib/data/roads"
SHAPEFILES = "lib/data/shapefiles"

desc "Load location events"
task :load_events, [:file] => :environment do |t, args|
  file = args.file
  events = []
  puts "Loading location events from #{file}"
  CSV.foreach("lib/data/location/#{file}") do |row|
    events << Event.new(:unique_id => row[0], :road_id => row[1], :distance => row[2].to_f)
    if events.size % BATCH_SIZE == 0
      Event.import events
      events = []
    end
  end
  Event.import events
end

desc "Download shapefiles from Minnesota Department of Transportation"
task :download_shapefiles do
  FileUtils.mkdir_p SHAPEFILES
  county_list = Nokogiri::HTML(open("#{BASE_URL}/html/county_text.html"))
  county_list.xpath('//html/body/table[5]/tr[2]/td[2]/table/tr/td/a').each do |county_link|
    county = county_link['href'].match(/([a-z]*)\.html/)[1]
    if county == "lakewoods"
      county = "lakeofthewoods"
    elsif county == "stlouis"
      county = "saintlouis"
    end
    download '/datafiles/county', "#{county}.zip"
  end
  
  # And of course, a one-off...
  download '/datafiles/statewide', 'StateTH.zip'
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
      puts "Generating roads SQL for #{base}"
      `shp2pgsql -a -s 200000 -W UTF-8 /tmp/#{base}/*.shp roads > #{ROADS}/#{base}.sql`
      `rm -rf /tmp/#{base}`
    end
  end
end

desc "Calculate and save latitude and longitude values for each event"
task :calculate_lat_lon => :environment do
  calculate :find_lat_lon
  calculate :find_lat_lon_begin
  calculate :find_lat_lon_end
end

private

def download url, file
  unless File.exists? "#{SHAPEFILES}/#{file}"
    File.open("#{SHAPEFILES}/#{file}",'wb') do |f|
      puts "Downloading #{file}"
      f.write(open("#{BASE_URL}/#{url}/#{file}").read)
    end
  end
end

def calculate message 
  offset = 0
  puts "Trying #{message}"
  locations = Event.send message, BATCH_SIZE, 0
  until locations.size == 0
    puts "Updating #{locations.size} events, starting at #{offset} with id: #{locations[0].id}"
    locations.each do |location|
      event = Event.find location.id
      event.update_attributes :longitude => location.longitude, :latitude => location.latitude
    end
    
    offset += locations.size
    locations = Event.send message, BATCH_SIZE, offset
  end
end