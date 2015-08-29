class AddColumnsToPayouts < ActiveRecord::Migration
  def change
    add_column :payouts, :fees, :decimal, scale: 2, precision: 15
    add_column :payouts, :paypal_batch_id, :string    
  end
end
