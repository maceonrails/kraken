class AddImageDetailsToProduct < ActiveRecord::Migration
  def change
    add_column :products, :picture_extension, :string
    add_column :products, :picture_base64, :text
  end
end
