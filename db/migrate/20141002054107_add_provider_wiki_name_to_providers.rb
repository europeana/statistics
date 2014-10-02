class AddProviderWikiNameToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :provider_wiki_name, :string
  end
end
