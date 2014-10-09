class AddHasNestedPageAndNestedPagesToCmsArticle < ActiveRecord::Migration
  def up
    add_column :cms_articles, :has_nested_pages, :boolean, :default => false
    add_column :cms_articles, :nested_pages, :json
  end
  def down
    remove_column :cms_articles, :has_nested_pages
    remove_column :cms_articles, :nested_pages
  end
end
