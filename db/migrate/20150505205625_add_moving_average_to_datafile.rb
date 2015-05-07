class AddMovingAverageToDatafile < ActiveRecord::Migration
  def change
    add_column :datafiles, :moving_average, :integer, default: 50
  end
end
