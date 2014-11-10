class AddPageBuilderConfigToSetting < ActiveRecord::Migration
  def change
    add_column :settings, :page_builder_config, :text
  end
end
