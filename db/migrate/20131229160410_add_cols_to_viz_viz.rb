class AddColsToVizViz < ActiveRecord::Migration
  def change
    add_column :viz_vizs, :chart, :string
    remove_column :viz_vizs, :viz_chart_id
  end
end
