class AddImagesToChoices < ActiveRecord::Migration
  def up
    add_attachment :choices, :image
  end

  def down
    remove_attachment :choices, :image
  end
end
