class ChangeDefaultForAllPublishersForQuestions < ActiveRecord::Migration
  def change
    change_column :questions, :all_publishers, :boolean, default: false
  end
end
