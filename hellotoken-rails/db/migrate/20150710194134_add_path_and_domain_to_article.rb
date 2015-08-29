class AddPathAndDomainToArticle < ActiveRecord::Migration
  def change
    add_column :articles, :path, :string
    add_column :articles, :domain, :string
    add_column :articles, :visits, :integer, default: 0 # eventually replace with visit table
  end
end
