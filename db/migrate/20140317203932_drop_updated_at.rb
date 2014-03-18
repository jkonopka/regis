class DropUpdatedAt < ActiveRecord::Migration

  def change
    remove_column :geocode_log_entries, :updated_at
  end

end