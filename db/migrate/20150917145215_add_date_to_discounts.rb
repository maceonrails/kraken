class AddDateToDiscounts < ActiveRecord::Migration
  def change
    add_column :discounts, :start_date, :datetime
    add_column :discounts, :end_date, :datetime
  end
end
