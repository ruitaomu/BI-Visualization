class AddTypeToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :type, :string, null: false, default: ''
  end
end
