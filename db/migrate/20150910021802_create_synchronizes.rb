class CreateSynchronizes < ActiveRecord::Migration
  def change
    create_table :synchronizes do |t|

      t.timestamps null: false
    end
  end
end
