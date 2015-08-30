class AddRoomIdToTables < ActiveRecord::Migration
  def change
    add_column :tables, :room_id, :uuid
  end
end
