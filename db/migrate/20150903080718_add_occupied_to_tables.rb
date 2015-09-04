class AddOccupiedToTables < ActiveRecord::Migration
  def change
    add_column :tables, :occupied, :boolean, default: false
  end
end
