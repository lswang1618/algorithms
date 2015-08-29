class AddCategoryRefToPublishers < ActiveRecord::Migration
  def change
    add_reference :publishers, :category, index: true
  end
end
