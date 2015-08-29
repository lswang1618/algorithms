class AddAgeColumnToReaders < ActiveRecord::Migration
  def change
    add_column :readers, :age, :integer
  end
end