class ChangePayoutCompletionColumn < ActiveRecord::Migration
  def change
    remove_column :payouts, :complete
    add_column :payouts, :status, :string, null: false
  end
end
