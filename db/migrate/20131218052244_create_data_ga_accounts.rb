class CreateDataGaAccounts < ActiveRecord::Migration
  def change
    create_table :data_ga_accounts do |t|
      t.integer :user_id
      t.integer :core_oauth_id
      t.string :name
      t.string :account_id
      t.string :profile_id
      t.timestamps
    end
  end
end
