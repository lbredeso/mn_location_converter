class Event < ActiveRecord::Base
  def self.find_lat_lon limit, offset
    self.find_by_sql base_query("events.distance > roads.begm and events.distance < roads.endm", limit, offset)
  end
  
  def self.find_lat_lon_begin limit, offset
    self.find_by_sql base_query("events.distance = roads.begm", limit, offset)
  end
  
  def self.find_lat_lon_end limit, offset
    self.find_by_sql base_query("events.distance = roads.endm", limit, offset)
  end
  
  private
  def self.base_query condition, limit, offset
    <<-SQL
      select id, st_x(point) as longitude, st_y(point) as latitude from 
        (
          select st_line_interpolate_point(
            st_transform(geometryn(roads.the_geom, 1), 4326), 
            (events.distance - least(roads.begm, roads.endm)) / greatest((@ roads.endm - roads.begm), 0.0000001)
          ) as point, events.id
          from events
          inner join roads on
            events.road_id = roads.tis_code and
            events.longitude is null and
            events.latitude is null and
            #{condition}
          where
            roads.traf_dir in ('B', 'I') and
            roads.shape_leng > 0.0
          order by
            events.id
        ) as event order by event.id limit #{limit} offset #{offset}
    SQL
  end
end