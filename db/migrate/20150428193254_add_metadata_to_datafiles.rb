class AddMetadataToDatafiles < ActiveRecord::Migration
  def change
    add_column :datafiles, :metadata, :json, default: {}, null: false
  end
end
