class RemoveUrlAndNameFromDatafiles < ActiveRecord::Migration
  def change
    remove_column :datafiles, :url
    remove_column :datafiles, :name
  end
end
