class AddVariousColumnsToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :complete, :boolean, default: false
    add_column :campaigns, :limit, :integer, null: false
  end
end
