class AddTisCodeIndex < ActiveRecord::Migration
  def up
    add_index :roads, :tis_code
  end

  def down
    remove_index :roads, :tis_code
  end
end
