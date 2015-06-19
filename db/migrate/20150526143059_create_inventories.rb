class CreateInventories < ActiveRecord::Migration
  def change
    create_table :inventories, id: :uuid do |t|
      t.uuid :company_id
      t.string :name
      t.integer :unit

      t.timestamps null: false
    end
    add_foreign_key :inventories, :companies
  end
end
