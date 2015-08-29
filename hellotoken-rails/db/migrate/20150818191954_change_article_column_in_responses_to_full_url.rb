class ChangeArticleColumnInResponsesToFullUrl < ActiveRecord::Migration
  def change
    rename_column :responses, :article, :full_url 
  end
end
