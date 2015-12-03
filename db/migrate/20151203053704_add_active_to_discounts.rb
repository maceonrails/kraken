class AddActiveToDiscounts < ActiveRecord::Migration
  def change
    add_column :discounts, :active, :boolean, default: true
  end
end
