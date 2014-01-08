class AddCols4850ToCmsArticles < ActiveRecord::Migration
  def change
    add_column :cms_articles, :is_star, :boolean
  end
end
