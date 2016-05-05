class AddClosingToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :closing_time, :datetime
  end
end
