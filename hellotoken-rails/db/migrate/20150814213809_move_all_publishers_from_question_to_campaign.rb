class MoveAllPublishersFromQuestionToCampaign < ActiveRecord::Migration
  def change
    remove_column :questions, :all_publishers
    add_column :campaigns, :all_publishers, :boolean, default: false
  end
end
