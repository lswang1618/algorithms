class ChangeDefaultsForGenderTargeting < ActiveRecord::Migration
  def change
    change_column_default :campaigns, :target_male, true
    change_column_default :campaigns, :target_female, true
    change_column_default :campaigns, :target_other, true
  end
end
