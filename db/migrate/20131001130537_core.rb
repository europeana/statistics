class Core < ActiveRecord::Migration
  def change
    
    create_table "cms_articles", :force => true do |t|
      t.string   "title"
      t.text     "description"
      t.date     "published_at"
      t.boolean  "is_published"
      t.datetime "created_at",   :null => false
      t.datetime "updated_at",   :null => false
      t.string   "slug"
    end

    add_index "cms_articles", ["slug"], :name => "index_cms_articles_on_slug"

    create_table "cms_images", :force => true do |t|
      t.string   "slug"
      t.datetime "created_at",         :null => false
      t.datetime "updated_at",         :null => false
      t.text     "image_file"
      t.string   "title"
      t.text     "url"
    end

    create_table "core_tags", :force => true do |t|
      t.string   "genre"
      t.string   "name"
      t.text     "description"
      t.datetime "created_at",    :null => false
      t.datetime "updated_at",    :null => false
    end

    create_table "data_filzs", :force => true do |t|
      t.string   "genre"
      t.string   "slug"
      t.string   "file_file_name"
      t.text     "content"
      t.datetime "created_at",        :null => false
      t.datetime "updated_at",        :null => false
      t.integer "core_oauth_id"
    end

    add_index "data_filzs", ["slug"], :name => "index_data_filzs_on_slug"

    create_table "delayed_jobs", :force => true do |t|
      t.integer  "priority",   :default => 0, :null => false
      t.integer  "attempts",   :default => 0, :null => false
      t.text     "handler",                   :null => false
      t.text     "last_error"
      t.datetime "run_at"
      t.datetime "locked_at"
      t.datetime "failed_at"
      t.string   "locked_by"
      t.string   "queue"
      t.datetime "created_at",                :null => false
      t.datetime "updated_at",                :null => false
    end

    add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

    create_table "users", :force => true do |t|
      t.string   "email",                  :default => "", :null => false
      t.string   "password",      :default => "", :null => false
      t.string   "password_hash"
      t.string   "password_salt"
      t.datetime "created_at",                             :null => false
      t.datetime "updated_at",                             :null => false
    end

    add_index "users", ["email"], :name => "index_users_on_email", :unique => true

    create_table "viz_charts", :force => true do |t|
      t.string   "name"
      t.string   "genre"
      t.text     "img"
      t.text     "mapping"
      t.datetime "created_at",  :null => false
      t.datetime "updated_at",  :null => false
      t.text     "description"
    end

    create_table "viz_vizs", :force => true do |t|
      t.string   "title"
      t.integer  "data_filz_id"
      t.integer  "viz_chart_id"
      t.text     "map"
      t.text     "mapped_output"
      t.text     "settings"
      t.datetime "created_at",    :null => false
      t.datetime "updated_at",    :null => false      
      t.string   "slug"
    end
    
    create_table :core_oauths do |t|
      t.string :token
      t.datetime :expires_at
      t.string :refresh_token
      t.string :profile
      t.string :name

      t.timestamps
    end
  
  end
end
