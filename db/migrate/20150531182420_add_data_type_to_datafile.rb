class AddDataTypeToDatafile < ActiveRecord::Migration
  def change
    add_column :datafiles, :data_type, :string, default: ''
  end
end
