class AddTestToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :test, :boolean, default: false
  end
end
