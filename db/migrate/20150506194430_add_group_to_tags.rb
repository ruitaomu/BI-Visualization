class AddGroupToTags < ActiveRecord::Migration
  def change
    add_column :tags, :group, :string
  end
end
