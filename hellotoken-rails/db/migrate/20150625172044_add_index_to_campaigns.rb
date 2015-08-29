class AddIndexToCampaigns < ActiveRecord::Migration
  def change
    add_reference :campaigns, :researcher, index: true, foreign_key: true
    add_reference :questions, :campaign, index: true, foreign_key: true
  end
end
