class MakeAccnUnique < ActiveRecord::Migration
  def up
    add_index :events, :accn, :unique => true
  end

  def down
    remove_index :events, :accn
  end
end
