class RenameTargetColumnsInCampaigns < ActiveRecord::Migration
  def change
    rename_column :campaigns, :target_males, :target_male
    rename_column :campaigns, :target_females, :target_female
  end
end
