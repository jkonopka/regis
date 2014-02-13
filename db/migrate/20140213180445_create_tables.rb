class CreateTables < ActiveRecord::Migration
  def self.up
    create_table :geocode_log_entries, :force => true do |t|
      #t.text :user_agent
      #t.text :request_path
      #t.text :filtered_params
      t.text :query
      t.text :result
      t.string :provider
      t.timestamps
    end
    add_index :geocode_log_entries, :provider
    add_index :geocode_log_entries, :created_at
    add_index :geocode_log_entries, :updated_at

  end

  def self.down
    remove_index :geocode_log_entries, :provider
    remove_index :geocode_log_entries, :created_at
    remove_index :geocode_log_entries, :updated_at
    drop_table :geocode_log_entries

  end
end
