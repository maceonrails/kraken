class AddDescriptionToProduct < ActiveRecord::Migration
  def change
    add_column :products, :description, :text
    add_column :products, :category, :string
    add_index  :products, :category
  end
end
