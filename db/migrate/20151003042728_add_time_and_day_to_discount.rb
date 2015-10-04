class AddTimeAndDayToDiscount < ActiveRecord::Migration
  def change
    add_column :discounts, :start_time, :time, default: '00:00'
    add_column :discounts, :end_time, :time, default: '23:59'
    add_column :discounts, :days, :text, array: true, default: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
  end
end
