class AddColsToVizViz < ActiveRecord::Migration
  def change
    add_column :viz_vizs, :chart, :string
  end
end
