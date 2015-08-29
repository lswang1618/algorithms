class AddDemographicsColumnsToCampaign < ActiveRecord::Migration
  def change
    change_table(:campaigns) do |t|
      t.column :target_gender, :boolean, default: false
      t.column :target_males, :boolean, default: false
      t.column :target_females, :boolean, default: false
      t.column :target_other, :boolean, default: false
      t.column :target_age, :boolean, default: false
      t.column :age_range_lower, :integer, default: 18
      t.column :age_range_upper, :integer, default: 99
    end
  end
end
