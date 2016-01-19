class ChangePrimaryKeyInAttendances < ActiveRecord::Migration
  def change
    add_column :attendances, :uuid, :uuid, default: "uuid_generate_v4()", null: false

    change_table :attendances do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE attendances ADD PRIMARY KEY (id);"
  end
end
