class CreateDiscounts < ActiveRecord::Migration
  def change
    create_table :discounts do |t|
      t.string :name
      t.string :amount
      t.uuid :product_id
      t.text :outlets, array: true

      t.timestamps null: false
    end
  end
end
