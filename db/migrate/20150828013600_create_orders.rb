class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders, id: :uuid do |t|
      t.string :name
      t.uuid :table_id
      t.uuid :servant_id

      t.timestamps null: false
    end
  end
end
