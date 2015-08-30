class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments, id: :uuid do |t|
      t.uuid :order_id
      t.string :payment_type
      t.decimal :amount, :precision => 10, :scale => 2
      t.decimal :discount, :precision => 10, :scale => 2
      t.boolean :void
      t.string :note

      t.timestamps null: false
    end
  end
end
