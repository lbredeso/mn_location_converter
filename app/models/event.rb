class Event < ActiveRecord::Base
  def self.find_lat_lon max
    self.find_by_sql base_query("events.distance > roads.begm and events.distance < roads.endm", max)
  end
  
  def self.find_lat_lon_begin max
    self.find_by_sql base_query("events.distance = roads.begm and events.latitude is null", max)
  end
  
  def self.find_lat_lon_end max
    self.find_by_sql base_query("events.distance = roads.endm and events.latitude is null", max)
  end
  
  private
  def self.base_query condition, max
    <<-SQL
      select st_x(point) as longitude, st_y(point) as latitude, id, unique_id, road_id, distance from 
        (
          select st_line_interpolate_point(
            st_transform(LineMerge(roads.the_geom), 4326), 
            (events.distance - roads.begm) / (roads.endm - roads.begm)
          ) as point, events.id, events.unique_id, events.road_id, events.distance
          from events
          inner join roads on
            events.road_id = roads.tis_code and
            #{condition}
          where
            roads.traf_dir in ('B', 'I')
          order by
            events.id
        ) as event limit #{max}
    SQL
  end
end