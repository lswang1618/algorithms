class AddColumnToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :demographic, :string
  end
end
