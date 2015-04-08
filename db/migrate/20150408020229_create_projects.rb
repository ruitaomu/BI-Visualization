class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.references :customer, index: true, foreign_key: true
      t.string :name

      t.timestamps null: false
    end
  end
end
