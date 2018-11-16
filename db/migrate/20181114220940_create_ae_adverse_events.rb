class CreateAeAdverseEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :ae_adverse_events do |t|
      t.bigint :project_id
      t.bigint :user_id
      t.bigint :subject_id
      t.integer :number
      t.text :description
      t.datetime :closed_at
      t.bigint :closer_id
      t.boolean :deleted, null: false, default: false
      t.timestamps
      t.index :project_id
      t.index :user_id
      t.index :subject_id
      t.index :number, unique: true
      t.index :closed_at
      t.index :closer_id
      t.index :deleted
    end
  end
end
