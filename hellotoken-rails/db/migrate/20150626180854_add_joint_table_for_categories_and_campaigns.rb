class AddJointTableForCategoriesAndCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns_categories, id: false do |t|
      t.belongs_to :campaign, index: true
      t.belongs_to :category, index: true
    end
  end
end
