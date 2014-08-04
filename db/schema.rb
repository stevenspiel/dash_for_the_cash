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

ActiveRecord::Schema.define(version: 20140731015452) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actions", force: true do |t|
    t.string   "action"
    t.integer  "player_id"
    t.integer  "round_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "base_positions", force: true do |t|
    t.integer  "position",   default: 0, null: false
    t.integer  "player_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "games", force: true do |t|
    t.integer  "initiator_id"
    t.integer  "opponent_id"
    t.boolean  "opponent_accepted", default: false
    t.integer  "winner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "players", force: true do |t|
    t.integer  "user_id"
    t.integer  "game_id"
    t.integer  "position",   default: 0,     null: false
    t.boolean  "ready",      default: false, null: false
    t.boolean  "winner",     default: false, null: false
    t.boolean  "defend",     default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rounds", force: true do |t|
    t.integer  "game_id"
    t.integer  "first_player_id"
    t.integer  "second_player_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "traps", force: true do |t|
    t.integer  "player_id"
    t.integer  "position",                  null: false
    t.boolean  "active",     default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "provider"
    t.string   "uid"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.boolean  "available",        default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
