class AddTextAtTopAndTextAtBottomToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :text_at_top, :text
    add_column :providers, :text_at_bottom, :text
    rename_column :providers, :provider_wiki_name, :wiki_name
  end
end
