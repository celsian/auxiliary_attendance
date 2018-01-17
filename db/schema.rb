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

ActiveRecord::Schema.define(version: 20180117195359) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "class_session_students", force: true do |t|
    t.integer  "class_session_id"
    t.integer  "student_id"
    t.string   "student_id_number"
    t.string   "reason"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "class_session_students", ["class_session_id"], name: "index_class_session_students_on_class_session_id", using: :btree
  add_index "class_session_students", ["student_id"], name: "index_class_session_students_on_student_id", using: :btree

  create_table "class_sessions", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.boolean  "closed",       default: false
    t.string   "participants"
    t.datetime "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "class_sessions", ["user_id"], name: "index_class_sessions_on_user_id", using: :btree

  create_table "students", force: true do |t|
    t.string   "id_number"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enabled",    default: true
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "teacher",                default: false
    t.boolean  "admin",                  default: false
    t.boolean  "peer_tutor",             default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
