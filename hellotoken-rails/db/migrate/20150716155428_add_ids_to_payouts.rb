class AddIdsToPayouts < ActiveRecord::Migration
  def change
    add_column :payouts, :alpha_id, :string
    add_column :payouts, :paypal_item_id, :string
  end
end
