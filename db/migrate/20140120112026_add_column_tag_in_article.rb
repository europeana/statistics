class AddColumnTagInArticle < ActiveRecord::Migration
  def up
    add_column :cms_articles, :tag, :string
    add_column :cms_articles, :home_page, :boolean
  end

  def down
  end
end
