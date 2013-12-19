class AddCols39ToCoreOauths < ActiveRecord::Migration
  def change
    add_column :core_oauths, :name, :string
    add_column :core_oauths, :email, :string
  end
end
