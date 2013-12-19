class AddColsToCoreOauths < ActiveRecord::Migration
  def change
    add_column :core_oauths, :user_id, :integer
    remove_column :core_oauths, :account_id
  end
end
