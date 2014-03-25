class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.boolean :masonry

      t.timestamps
    end
  end
end
