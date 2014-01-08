class AddCols7485ToCoreTags < ActiveRecord::Migration
  def change
    add_column :core_tags, :sort_order, :integer
  end
end
