class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms, id: :uuid do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
