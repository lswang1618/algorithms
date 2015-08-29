class CreatePayouts < ActiveRecord::Migration
  def change
    create_table :payouts do |t|
      t.references :publisher
      t.decimal :amount, null: false, scale: 2, precision: 15
      t.boolean :complete, default: false
      t.timestamps
    end
  end
end
