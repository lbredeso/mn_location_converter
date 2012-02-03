class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :accn
      t.string :road_id
      t.float :distance

      t.timestamps
    end
  end
end
