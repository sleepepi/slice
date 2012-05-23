class CreateSubjects < ActiveRecord::Migration
  def change
    create_table :subjects do |t|
      t.integer :project_id
      t.string :subject_code
      t.integer :user_id
      t.boolean :deleted, default: false, null: false

      t.timestamps
    end
  end
end
