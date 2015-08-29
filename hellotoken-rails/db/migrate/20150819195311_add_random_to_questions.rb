class AddRandomToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :random, :boolean, default: false
  end
end
