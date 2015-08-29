class AddLogoToPublisher < ActiveRecord::Migration
  def change
    add_attachment :publishers, :logo
  end
end
