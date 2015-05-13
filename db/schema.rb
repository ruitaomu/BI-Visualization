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

ActiveRecord::Schema.define(version: 20150508185511) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "customers", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "datafiles", force: :cascade do |t|
    t.integer  "video_id",                    null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.json     "metadata",       default: {}, null: false
    t.integer  "moving_average", default: 50
  end

  add_index "datafiles", ["video_id"], name: "index_datafiles_on_video_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.integer  "customer_id"
    t.string   "name"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "type",        default: "",    null: false
    t.boolean  "archived",    default: false, null: false
  end

  add_index "projects", ["customer_id"], name: "index_projects_on_customer_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.json   "permissions", default: {}
  end

  add_index "roles", ["name"], name: "index_roles_on_name", unique: true, using: :btree

  create_table "roles_users", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "roles_users", ["user_id", "role_id"], name: "index_roles_users_on_user_id_and_role_id", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string "name"
    t.string "value"
  end

  create_table "tags", force: :cascade do |t|
    t.integer  "video_id",   null: false
    t.string   "name",       null: false
    t.integer  "starts",     null: false
    t.integer  "ends",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "group"
  end

  add_index "tags", ["ends"], name: "index_tags_on_ends", using: :btree
  add_index "tags", ["name"], name: "index_tags_on_name", using: :btree
  add_index "tags", ["starts"], name: "index_tags_on_starts", using: :btree
  add_index "tags", ["video_id"], name: "index_tags_on_video_id", using: :btree

  create_table "testers", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.json     "metadata",   default: {}, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "videos", force: :cascade do |t|
    t.integer "project_id"
    t.integer "tester_id"
    t.string  "name"
    t.string  "url"
  end

  add_index "videos", ["project_id"], name: "index_videos_on_project_id", using: :btree
  add_index "videos", ["tester_id"], name: "index_videos_on_tester_id", using: :btree

  add_foreign_key "projects", "customers"
  add_foreign_key "videos", "projects"
  add_foreign_key "videos", "testers"
end
