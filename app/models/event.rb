class Event < ActiveRecord::Base
  scope :located, lambda {
    where('events.latitude is not null and events.longitude is not null')
  }
  
  def self.find_lat_lon limit
    self.find_by_sql base_query("events.distance > roads.begm and events.distance < roads.endm", limit)
  end
  
  def self.find_lat_lon_begin limit
    self.find_by_sql base_query("events.distance = roads.begm", limit)
  end
  
  def self.find_lat_lon_end limit
    self.find_by_sql base_query("events.distance = roads.endm", limit)
  end
  
  private
  def self.base_query condition, limit
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
            roads.the_geom is not null and
            roads.traf_dir in ('B', 'I') and
            roads.shape_leng > 0.0
          where
            events.longitude is null and
            events.latitude is null and
            #{condition}
          order by
            events.id
        ) as event order by event.id limit #{limit} offset 0
    SQL
  end
end