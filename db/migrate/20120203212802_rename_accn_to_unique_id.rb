class RenameAccnToUniqueId < ActiveRecord::Migration
  def change
    rename_column :events, :accn, :unique_id
  end
end
