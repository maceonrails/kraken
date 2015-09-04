class AddDefaultForVoideInOrderItems < ActiveRecord::Migration
  def change
  	change_column :order_items, :void, :boolean, default: false
  end
end
