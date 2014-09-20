class AddTableProviders < ActiveRecord::Migration
  def up
    create_table :providers do |t|
      t.string :provider_id
      t.string :name
      t.timestamps
    end

  end

  def down
  end
end
