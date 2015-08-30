class CreateProductChoices < ActiveRecord::Migration
  def change
    create_table :product_choices, id: :uuid do |t|
      t.uuid :product_id
      t.uuid :choice_id

      t.timestamps null: false
    end
  end
end
