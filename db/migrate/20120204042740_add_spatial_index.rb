class AddSpatialIndex < ActiveRecord::Migration
  def up
    execute %{
      SELECT AddGeometryColumn('','roads','the_geom','200000','MULTILINESTRINGM',3);
    }
  end

  def down
  end
end
