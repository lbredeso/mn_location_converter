class Event < ActiveRecord::Base
  def self.find_lat_lon limit, offset
    self.find_by_sql base_query("events.distance > roads.begm and events.distance < roads.endm", limit, offset)
  end
  
  def self.find_lat_lon_begin limit, offset
    self.find_by_sql base_query("events.distance = roads.begm and events.latitude is null", limit, offset)
  end
  
  def self.find_lat_lon_end limit, offset
    self.find_by_sql base_query("events.distance = roads.endm and events.latitude is null", limit, offset)
  end
  
  private
  def self.base_query condition, limit, offset
    <<-SQL
      select st_x(point) as longitude, st_y(point) as latitude, id, unique_id, road_id, distance from 
        (
          select st_line_interpolate_point(
            st_transform(geometryn(roads.the_geom, 1), 4326), 
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
        ) as event limit #{limit} offset #{offset}
    SQL
  end
end