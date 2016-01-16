class AddLastDateToSynchronizes < ActiveRecord::Migration
  def change
    add_column :synchronizes, :last_date, :datetime
  end
end
