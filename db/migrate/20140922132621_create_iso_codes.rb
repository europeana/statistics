class CreateIsoCodes < ActiveRecord::Migration
  def change
    create_table :iso_codes do |t|
      t.string :code
      t.string :country

      t.timestamps
    end
  end
end
