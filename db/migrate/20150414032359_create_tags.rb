class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.references :video, index: true, null: false
      t.string :name, null: false
      t.integer :starts, null: false
      t.integer :ends, null: false

      t.timestamps null: false
    end
    add_index :tags, :name
    add_index :tags, :starts
    add_index :tags, :ends
  end
end
