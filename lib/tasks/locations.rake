require 'csv'

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