class CreateTagSeries < ActiveRecord::Migration
  def change
    create_table :tag_series do |t|
      t.references :video, index: true, foreign_key: true
      t.string :name
      t.string :tag_ids, array: true, default: []

      t.timestamps null: false
    end
  end
end
