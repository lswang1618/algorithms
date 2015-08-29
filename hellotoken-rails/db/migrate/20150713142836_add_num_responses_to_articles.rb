class AddNumResponsesToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :num_responses, :integer, default: 0
  end
end
