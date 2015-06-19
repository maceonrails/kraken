class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles, id: :uuid do |t|
      t.uuid :user_id
      t.string :name
      t.text :address
      t.string :phone
      t.date :join_at
      t.date :contract_until

      t.timestamps null: false
    end
    add_foreign_key :profiles, :users, on_delete: :cascade
  end
end
