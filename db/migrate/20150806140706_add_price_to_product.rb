class AddPriceToProduct < ActiveRecord::Migration
  def change
    add_column :products, :price, :string
  end
end
