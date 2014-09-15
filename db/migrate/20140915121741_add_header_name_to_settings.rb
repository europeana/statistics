class AddHeaderNameToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :header_name, :string
  end
end
