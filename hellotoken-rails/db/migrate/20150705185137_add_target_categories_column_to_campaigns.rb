class AddTargetCategoriesColumnToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :target_categories, :boolean, default: false
  end
end
