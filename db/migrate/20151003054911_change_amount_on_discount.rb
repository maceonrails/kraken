class ChangeAmountOnDiscount < ActiveRecord::Migration
  def change
  	remove_column :discounts, :amount, :string
    add_column :discounts, :amount, :decimal, :precision => 25, :scale => 2
  end
end
