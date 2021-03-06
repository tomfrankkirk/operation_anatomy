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

ActiveRecord::Schema.define(version: 20190215194934) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "dictionary_entries", force: :cascade do |t|
    t.string   "title"
    t.string   "definition"
    t.string   "example"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["title"], name: "index_dictionary_entries_on_title", using: :btree
  end

  create_table "feedback_records", force: :cascade do |t|
    t.string   "tone"
    t.string   "comment"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean  "solved"
    t.index ["user_id"], name: "index_feedback_records_on_user_id", using: :btree
  end

  create_table "questions", force: :cascade do |t|
    t.integer  "number"
    t.integer  "level"
    t.string   "body"
    t.string   "possibleSolutions"
    t.integer  "topic_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["topic_id"], name: "index_questions_on_topic_id", using: :btree
  end

  create_table "systems", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "topics", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "system_id"
    t.string   "short_name"
    t.jsonb    "paths",       default: {}
    t.text     "level_names"
    t.index ["short_name"], name: "index_topics_on_short_name", using: :btree
    t.index ["system_id"], name: "index_topics_on_system_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "name"
    t.string   "password"
    t.text     "questionIDs"
    t.jsonb    "scoresDictionary",       default: {}
    t.integer  "currentScore",           default: 0
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.jsonb    "levelViewsDictionary",   default: {}
    t.boolean  "revisionMode",           default: false
    t.boolean  "isAdmin",                default: false
    t.boolean  "inAdminMode",            default: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["scoresDictionary"], name: "index_users_on_scoresDictionary", using: :btree
  end

  add_foreign_key "topics", "systems"
end
