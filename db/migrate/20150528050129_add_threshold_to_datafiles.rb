class AddThresholdToDatafiles < ActiveRecord::Migration
  def change
    add_column :datafiles, :threshold, :integer, default: 1
  end
end
