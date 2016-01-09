class CreateAttendances < ActiveRecord::Migration
  def change
    create_table :attendances do |t|
      t.uuid :user_id
      t.date :date
      t.datetime :come_in
      t.datetime :come_out

      t.timestamps null: false
    end
  end
end
