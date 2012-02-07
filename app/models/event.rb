class Event < ActiveRecord::Base
  def self.find_lat_lon
    self.find_by_sql <<-SQL
      select st_x(point) as longitude, st_y(point) as latitude, id, unique_id, road_id, distance from 
        (
          select st_line_interpolate_point(
            st_transform(LineMerge(roads.the_geom), 4326), 
            events.distance / st_length(roads.the_geom)
          ) as point, events.id, events.unique_id, events.road_id, events.distance
          from events
          join roads on 
            events.road_id = roads.tis_code AND 
            events.distance > roads.begm AND 
            events.distance <= roads.endm
        ) as event limit 10;
    SQL
  end
end