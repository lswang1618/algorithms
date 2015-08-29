class ChangeStatusColumnForPayouts < ActiveRecord::Migration
  def change
  	change_column :payouts, :status, :string, null: false, default: "NEW"
  end
end
