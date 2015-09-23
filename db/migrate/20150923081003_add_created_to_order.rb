class AddCreatedToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :created, :boolean, default: false
  end
end
