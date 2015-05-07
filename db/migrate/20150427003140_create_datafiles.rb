class CreateDatafiles < ActiveRecord::Migration
  def change
    create_table :datafiles do |t|
      t.references :video, index: true, null: false
      t.string :name, null: false
      t.string :url

      t.timestamps null: false
    end
  end
end
