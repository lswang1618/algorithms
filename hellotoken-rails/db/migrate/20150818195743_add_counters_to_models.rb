class AddCountersToModels < ActiveRecord::Migration
  def change
    add_column :choices, :num_responses, :integer, default: 0
    add_column :questions, :num_responses, :integer, default: 0
  end
end
