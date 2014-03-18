# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140317203932) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cached_results", force: true do |t|
    t.datetime "created_at"
    t.text     "provider"
    t.text     "query"
    t.text     "result"
    t.text     "key"
  end

  add_index "cached_results", ["key"], name: "index_cached_results_on_key", using: :btree

  create_table "geocode_log_entries", force: true do |t|
    t.text     "query"
    t.text     "result"
    t.string   "provider"
    t.datetime "created_at"
  end

  add_index "geocode_log_entries", ["created_at"], name: "index_geocode_log_entries_on_created_at", using: :btree
  add_index "geocode_log_entries", ["provider"], name: "index_geocode_log_entries_on_provider", using: :btree

end
