class CreateSheets < ActiveRecord::Migration[4.2]
  def change
    create_table :sheets do |t|
      t.string :name
      t.text :description
      t.integer :design_id
      t.date :study_date
      t.integer :project_id
      t.integer :subject_id
      t.integer :user_id
      t.boolean :deleted, default: false, null: false

      t.timestamps
    end
  end
end
