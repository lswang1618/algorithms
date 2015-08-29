class AddCostToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :cost, :decimal, scale: 2, precision: 15, default: 0
  end
end
