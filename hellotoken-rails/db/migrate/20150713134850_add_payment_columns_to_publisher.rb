class AddPaymentColumnsToPublisher < ActiveRecord::Migration
  def change
    add_column :publishers, :total_earnings, :decimal, scale: 2, precision: 15, default: 0
    add_column :publishers, :paid, :decimal, scale: 2, precision: 15, default: 0
  end
end
