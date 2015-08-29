class AddQuestionsActiveToPublishers < ActiveRecord::Migration
  def change
    add_column :publishers, :questions_active, :boolean, default: true
  end
end
