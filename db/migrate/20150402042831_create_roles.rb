class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name
      t.json :permissions, default: {}
    end
    add_index :roles, :name, unique: true

    create_table :roles_users, id: false do |t|
      t.references :user
      t.references :role
    end
    add_index :roles_users, %i(user_id role_id)
  end
end
