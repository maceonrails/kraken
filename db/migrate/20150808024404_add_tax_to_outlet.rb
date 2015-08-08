class AddTaxToOutlet < ActiveRecord::Migration
  def change
    enable_extension 'hstore'
    add_column :outlets, :taxs, :hstore
  end
end
