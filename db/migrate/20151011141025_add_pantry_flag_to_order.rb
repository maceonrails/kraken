class AddPantryFlagToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :pantry_created, :boolean, default: false
end
end
