class AddContinentToIsoCode < ActiveRecord::Migration
  def change
    add_column :iso_codes, :continent, :string
  end
end
