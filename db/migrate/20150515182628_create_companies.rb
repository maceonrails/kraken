class CreateCompanies < ActiveRecord::Migration
  def change
    execute 'CREATE EXTENSION "uuid-ossp" SCHEMA public'

    create_table :companies, id: :uuid do |t|
      t.string :name
      t.text :address
      t.date :join_at
      t.date :expires
      t.string :email
      t.string :phone
      t.string :mobile
      t.string :logo

      t.timestamps null: false
    end
  end
end
