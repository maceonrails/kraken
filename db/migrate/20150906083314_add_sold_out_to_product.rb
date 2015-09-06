class AddSoldOutToProduct < ActiveRecord::Migration
  def change
    add_column :products, :sold_out, :boolean
  end
end
