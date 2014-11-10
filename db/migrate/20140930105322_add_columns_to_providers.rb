class AddColumnsToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :requested_at, :datetime
    add_column :providers, :request_end, :datetime
    add_column :providers, :is_processed, :boolean
  end
end
