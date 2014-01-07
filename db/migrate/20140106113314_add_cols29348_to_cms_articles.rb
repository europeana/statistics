class AddCols29348ToCmsArticles < ActiveRecord::Migration
  def change
    add_column :cms_articles, :core_tag_id, :integer
  end
end
