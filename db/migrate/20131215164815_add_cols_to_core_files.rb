class AddColsToCoreFiles < ActiveRecord::Migration
  def change
    add_column :core_files, :commit_message, :text
  end
end
