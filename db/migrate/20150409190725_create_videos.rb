class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.references :project, index: true, foreign_key: true
      t.references :tester, index: true, foreign_key: true
      t.string :name
      t.string :url
    end
  end
end
