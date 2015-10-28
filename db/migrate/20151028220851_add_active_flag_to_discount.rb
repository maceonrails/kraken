class AddActiveFlagToDiscount < ActiveRecord::Migration
  def change
    add_column :discounts, :isactive, :boolean, default: true
  end
end
