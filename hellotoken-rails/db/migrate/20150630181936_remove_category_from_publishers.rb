class RemoveCategoryFromPublishers < ActiveRecord::Migration
  def change
    remove_column :publishers, :category, :string
  end
end
