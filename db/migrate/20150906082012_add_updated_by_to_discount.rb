class AddUpdatedByToDiscount < ActiveRecord::Migration
  def change
    add_column :discounts, :updated_by, :uuid
  end
end
