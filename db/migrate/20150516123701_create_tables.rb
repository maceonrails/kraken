class CreateTables < ActiveRecord::Migration
  def change
    create_table :tables, id: :uuid do |t|
      t.string :name
      t.string :location
      t.boolean :splited, default: false
      t.uuid :order_id
      t.uuid :parent_id
      t.integer :status

      t.timestamps null: false
    end
    add_index :tables, :location
  end
end
