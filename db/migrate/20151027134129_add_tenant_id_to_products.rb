class AddTenantIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :tenant_id, :uuid
  end
end
