class CreateTesters < ActiveRecord::Migration
  def change
    create_table :testers do |t|
      t.references :project, index: true, foreign_key: true
      t.string :name

      t.timestamps null: false
    end
  end
end
