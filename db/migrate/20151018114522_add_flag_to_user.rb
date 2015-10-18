class AddFlagToUser < ActiveRecord::Migration
  def change
    add_column :users, :start_login, :datetime
  end
end
