class CreateProviders < ActiveRecord::Migration
  def change
    drop_table :providers
    create_table :providers do |t|
      t.string :provider_id
      t.string :name
      t.string :provider_type
      t.timestamps
    end
  end
end
