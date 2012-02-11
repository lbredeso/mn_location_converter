class AddRoadAndDistanceIndexes < ActiveRecord::Migration
  def up
    add_index :events, [:road_id, :distance]
    add_index :roads, [:tis_code, :begm, :endm]
  end

  def down
    remove_index :events, [:road_id, :distance]
    remove_index :roads, [:tis_code, :begm, :endm]
  end
end
