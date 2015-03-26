class AddRoleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :role, :string, limit: 16
    add_index :users, :role
    execute "UPDATE users SET role = 'admin'"
  end
end
