class AddCategoryToPublishers < ActiveRecord::Migration
  def change
    add_column :publishers, :category, :string
  end
end
