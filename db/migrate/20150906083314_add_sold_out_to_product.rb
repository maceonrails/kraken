class AddSoldOutToProduct < ActiveRecord::Migration
  def change
    add_column :products, :sold_out, :boolean, default: false
  end
end
