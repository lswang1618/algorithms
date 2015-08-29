class AddFreeDemographicsColumnToPublishers < ActiveRecord::Migration
  def change
    add_column :publishers, :free_demographics, :boolean, default: false
  end
end
