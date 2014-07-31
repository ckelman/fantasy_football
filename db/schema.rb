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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140731151116) do

  create_table "players", force: true do |t|
    t.string   "name"
    t.string   "position"
    t.string   "team"
    t.integer  "age"
    t.integer  "experience"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "number"
    t.integer  "weight"
  end

  create_table "seasons", force: true do |t|
    t.integer  "year"
    t.string   "team"
    t.integer  "games_played"
    t.integer  "rush_attempts"
    t.integer  "rush_yards"
    t.float    "rush_avg"
    t.integer  "rush_td"
    t.integer  "receptions"
    t.integer  "rec_yards"
    t.float    "rec_avg"
    t.integer  "rec_td"
    t.integer  "pass_attempts"
    t.integer  "pass_complete"
    t.float    "complete_pct"
    t.integer  "pass_yards"
    t.float    "pass_avg"
    t.integer  "pass_td"
    t.integer  "interceptions"
    t.float    "rating"
    t.integer  "fumbles"
    t.integer  "player_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "total_points"
    t.integer  "experience"
    t.integer  "age"
    t.float    "change_from_last"
    t.string   "position"
  end

end
