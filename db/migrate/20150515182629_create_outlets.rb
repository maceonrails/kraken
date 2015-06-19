class CreateOutlets < ActiveRecord::Migration
  def change
    create_table :outlets, id: :uuid do |t|
      t.string :name
      t.text :address
      t.uuid :company_id
      t.string :email
      t.string :phone
      t.string :mobile

      t.timestamps null: false
    end

    add_foreign_key :outlets, :companies
  end
end
