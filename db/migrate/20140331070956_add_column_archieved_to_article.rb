class AddColumnArchievedToArticle < ActiveRecord::Migration
  def change
    add_column :cms_articles, :archieved, :boolean
  end
end
