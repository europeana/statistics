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

ActiveRecord::Schema.define(:version => 20131218052244) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.string   "slug"
    t.text     "description"
    t.string   "license"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.text     "api_token"
    t.text     "domain"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "accounts", ["slug"], :name => "index_accounts_on_slug"

  create_table "core_alerts", :force => true do |t|
    t.integer  "account_id"
    t.integer  "alertable_id"
    t.string   "alertable_type"
    t.string   "action"
    t.text     "description"
    t.integer  "updated_by"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "core_files", :force => true do |t|
    t.integer  "account_id"
    t.string   "genre"
    t.string   "slug"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.string   "file_file_size"
    t.boolean  "is_pending"
    t.text     "content"
    t.text     "error_log"
    t.string   "category"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.text     "commit_message"
  end

  add_index "core_files", ["slug"], :name => "index_core_files_on_slug"

  create_table "core_oauths", :force => true do |t|
    t.string   "app"
    t.string   "token"
    t.string   "refresh_token"
    t.datetime "token_expires_at"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "user_id"
    t.string   "name"
    t.string   "email"
  end

  create_table "core_visits", :force => true do |t|
    t.integer  "current_user_id"
    t.string   "visitable_type"
    t.integer  "visitable_id"
    t.text     "path_from"
    t.text     "path_to"
    t.text     "http_method"
    t.string   "ip"
    t.string   "lang"
    t.text     "caller_host"
    t.boolean  "is_bot"
    t.text     "os"
    t.text     "os_version"
    t.text     "device_genre"
    t.text     "device_brand"
    t.text     "device_model"
    t.text     "browser"
    t.text     "browser_version"
    t.datetime "created_at",      :null => false
    t.text     "raw_user_agent"
    t.datetime "updated_at",      :null => false
    t.string   "browser_genre"
    t.string   "day_of_week"
    t.integer  "day"
    t.integer  "month"
    t.integer  "year"
    t.integer  "hour"
    t.integer  "account_id"
  end

  create_table "data_ga_accounts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "core_oauth_id"
    t.string   "name"
    t.string   "account_id"
    t.string   "profile_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "permissions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "account_id"
    t.string   "role"
    t.string   "email"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "permissions", ["account_id"], :name => "index_permissions_on_account_id"
  add_index "permissions", ["user_id"], :name => "index_permissions_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "username"
    t.string   "email",                  :default => "", :null => false
    t.string   "slug"
    t.text     "bio"
    t.string   "time_zone"
    t.text     "url"
    t.string   "company"
    t.string   "location"
    t.string   "gravatar_email"
    t.string   "public_email"
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0,  :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.string   "authentication_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["slug"], :name => "index_users_on_slug"

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
