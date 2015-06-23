class AddAutoToTags < ActiveRecord::Migration
  def change
    add_column :tags, :auto, :boolean, default: false
  end
end
