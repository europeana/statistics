class CreateCoreOauths < ActiveRecord::Migration
  def change
    create_table :core_oauths do |t|
      t.integer :account_id
      t.string :app
      t.string :token
      t.string :refresh_token
      t.datetime :token_expires_at
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end
end
