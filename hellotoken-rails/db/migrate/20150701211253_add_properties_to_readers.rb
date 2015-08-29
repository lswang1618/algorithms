class AddPropertiesToReaders < ActiveRecord::Migration
  def change
    change_table(:readers) do |t|
      t.column :last_page, :string
      t.column :last_ip, :string
      t.column :initial_page, :string
      t.column :initial_ip, :string
      t.column :city, :string
      t.column :region, :string
      t.column :country, :string
      t.column :timezone, :string
    end  
  end
end
