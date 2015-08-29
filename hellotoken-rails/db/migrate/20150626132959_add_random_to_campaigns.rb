class AddRandomToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :random, :boolean
  end
end
