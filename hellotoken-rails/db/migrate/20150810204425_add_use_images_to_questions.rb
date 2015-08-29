class AddUseImagesToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :use_images, :boolean, default: false
  end
end
