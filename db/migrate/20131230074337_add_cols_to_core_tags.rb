class AddColsToCore::Tags < ActiveRecord::Migration
  def change
    add_column :core_tags, :slug, :string
  end
end
