class AddPositionToCmsArticles < ActiveRecord::Migration
  def change
    add_column :cms_articles, :position, :integer
  end
end
