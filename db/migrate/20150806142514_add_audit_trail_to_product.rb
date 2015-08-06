class AddAuditTrailToProduct < ActiveRecord::Migration
  def change
    add_column :products, :updated_by, :uuid
  end
end
