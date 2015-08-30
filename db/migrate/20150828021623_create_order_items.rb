class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items, id: :uuid do |t|
      t.uuid :order_id
      t.uuid :product_id
      t.integer :quantity
      t.uuid :choice_id
      t.string :note
      t.uuid :payment_id
      t.boolean :served
      t.boolean :void

      t.timestamps null: false
    end
  end
end
