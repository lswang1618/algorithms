class AddColumnToReaders < ActiveRecord::Migration
  def change
    add_column :readers, :gender, :string
  end
end
