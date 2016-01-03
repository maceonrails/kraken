class AddOcAmountToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :oc_amount, :decimal, :precision => 20, :scale => 2, default: 0
  end
end
