class AddErrorMessageToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :error_message, :string
  end
end
