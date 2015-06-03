class AddMetadataToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :metadata, :json, null: false, default: {}
  end
end
