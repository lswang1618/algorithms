class RemoveCategoryStringColumnFromCampaigns < ActiveRecord::Migration
  def change
    remove_column :campaigns, :category, :string
  end
end
