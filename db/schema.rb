# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120204024026) do

  create_table "events", :force => true do |t|
    t.string "unique_id"
    t.string "road_id"
    t.float  "distance"
  end

  add_index "events", ["unique_id"], :name => "index_events_on_accn", :unique => true

  create_table "roads", :primary_key => "gid", :force => true do |t|
    t.string  "str_name",   :limit => 42
    t.string  "str_pfx",    :limit => 2
    t.string  "base_nam",   :limit => 50
    t.string  "str_type",   :limit => 4
    t.string  "str_sfx",    :limit => 2
    t.string  "e_911",      :limit => 1
    t.string  "tis_code",   :limit => 11
    t.string  "rte_syst",   :limit => 2
    t.string  "rte_num",    :limit => 5
    t.string  "divid",      :limit => 1
    t.string  "traf_dir",   :limit => 1
    t.string  "tis_one",    :limit => 16
    t.string  "status",     :limit => 1
    t.date    "date_pro"
    t.date    "date_act"
    t.date    "date_ret"
    t.date    "date_edt"
    t.decimal "shape_leng"
    t.float   "begm"
    t.float   "endm"
    t.string  "cnty_code",  :limit => 254
    t.string  "directiona", :limit => 254
  end

  add_index "roads", ["tis_code"], :name => "index_roads_on_tis_code"

end
