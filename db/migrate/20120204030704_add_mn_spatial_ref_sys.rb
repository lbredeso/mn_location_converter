class AddMnSpatialRefSys < ActiveRecord::Migration
  def up
    execute %{
      insert into spatial_ref_sys values (200000, 'NOONE', '0', 'PROJCS["NAD_1983_UTM_Zone_15N",GEOGCS["GCS_North_American_1983",DATUM["D_North_American_1983",SPHEROID["GRS_1980",6378137.0,298.257222101]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]],PROJECTION["Transverse_Mercator"],PARAMETER["False_Easting",500000.0],PARAMETER["False_Northing",0.0],PARAMETER["Central_Meridian",-93.0],PARAMETER["Scale_Factor",0.9996],PARAMETER["Latitude_Of_Origin",0.0],UNIT["Meter",1.0]]', '+proj=utm +zone=15 +ellps=GRS80 +units=m +no_defs');
    }
  end

  def down
    execute %{
      delete from spatial_ref_sys where srid = 200000;
    }
  end
end
