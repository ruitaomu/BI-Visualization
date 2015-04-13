class AddMetadataToTesters < ActiveRecord::Migration
  def change
    add_column :testers, :metadata, :json, null: false, default: {}
  end
end
