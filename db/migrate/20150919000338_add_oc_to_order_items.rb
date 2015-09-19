class AddOcToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :oc_quantity, :integer, default: 0
    add_column :order_items, :oc_by, :uuid
    add_column :order_items, :oc_note, :string
  end
end
