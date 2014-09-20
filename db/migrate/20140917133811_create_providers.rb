class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|

      t.timestamps
    end
  end
end
