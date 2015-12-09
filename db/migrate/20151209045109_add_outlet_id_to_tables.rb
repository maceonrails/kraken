class AddOutletIdToTables < ActiveRecord::Migration
  def change
    add_column :tables, :outlet_id, :uuid
  end
end
