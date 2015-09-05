class AddTakeAwayFlagToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :saved_choice, :string
    add_column :order_items, :take_away, :boolean, default: false
    add_column :order_items, :void_by, :uuid

    add_index  :order_items, :void_by
  end
end
