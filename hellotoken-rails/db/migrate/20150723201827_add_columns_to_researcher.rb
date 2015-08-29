class AddColumnsToResearcher < ActiveRecord::Migration
  def change
    add_column :researchers, :company_name, :string
    add_column :researchers, :website, :string
  end
end
