require 'csv'
require 'nokogiri'
require 'open-uri'

BASE_URL = 'http://www.dot.state.mn.us/maps/gisbase'
ROADS = "lib/data/roads"
SHAPEFILES = "lib/data/shapefiles"

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

private

def download url, file
  unless File.exists? "#{SHAPEFILES}/#{file}"
    File.open("#{SHAPEFILES}/#{file}",'wb') do |f|
      puts "Downloading #{file}"
      f.write(open("#{BASE_URL}/#{url}/#{file}").read)
    end
  end
end