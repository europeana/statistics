class AddColumnIsDeleteToArticle < ActiveRecord::Migration
  def change
    add_column :cms_articles, :is_deleted, :boolean
  end
end
