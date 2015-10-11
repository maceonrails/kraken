class AddPercentageToDiscount < ActiveRecord::Migration
  def change
    add_column :discounts, :percentage, :string
  end
end
