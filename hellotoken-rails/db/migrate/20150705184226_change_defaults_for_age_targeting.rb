class ChangeDefaultsForAgeTargeting < ActiveRecord::Migration
  def change
    change_column_default :campaigns, :age_range_lower, 0
  end
end
