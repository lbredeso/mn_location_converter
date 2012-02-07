class AddAnotherSpatialIndex < ActiveRecord::Migration
  def up
    execute %{
      CREATE INDEX roads_the_geom_gist
        ON roads
      USING gist
      (the_geom);
    }
  end

  def down
    execute %{
      drop index roads_the_geom_gist;
    }
  end
end
