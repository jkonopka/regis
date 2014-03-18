class CreateCachedResults < ActiveRecord::Migration

  def up
    create_table :cached_results do |t|
      t.timestamp :created_at
      t.text :query
      t.text :result
      t.text :key
    end
    add_index :cached_results, :key
  end

  def down
    drop_table :cached_results
  end

end
