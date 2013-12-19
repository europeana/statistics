class Core < ActiveRecord::Migration
  def change
    
    create_table "users", :force => true do |t|
      t.string   "name"
      t.string   "username"
      t.string   "email",        :default => "", :null => false
      t.string   "password",     :default => "", :null => false
      t.string   "password",     :default => "", :null => false
      t.string   "password",     :default => "", :null => false
      t.string   "password_hash"
      t.string   "password_salt"
      t.datetime "created_at",                             :null => false
      t.datetime "updated_at",                             :null => false
    end

    add_index "users", ["email"], :name => "index_users_on_email", :unique => true
            
  end
end
