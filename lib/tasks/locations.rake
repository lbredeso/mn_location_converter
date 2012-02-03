require 'csv'
require 'nokogiri'
require 'open-uri'

desc "Load location events"
task :load_events, [:year] => :environment do |t, args|
  year = args.year
  events = []
  puts "Loading location events for #{year}"
  CSV.foreach("lib/data/location/mn-#{year}-loc.csv") do |row|
    events << Event.new(:accn => row[0], :road_id => row[1], :distance => row[2].to_f)
    if events.size % 1000 == 0
      Event.import events
      events = []
    end
  end
  Event.import events
end

desc "Download shapefiles from Minnesota Department of Transportation"
task :download_shapefiles do
  shapefiles = "lib/data/shapefiles"
  FileUtils.mkdir_p shapefiles
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