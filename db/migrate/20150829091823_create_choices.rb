class CreateChoices < ActiveRecord::Migration
  def change
    create_table :choices, id: :uuid do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
