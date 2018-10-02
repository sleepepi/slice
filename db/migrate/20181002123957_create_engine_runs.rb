class CreateEngineRuns < ActiveRecord::Migration[5.2]
  def change
    create_table :engine_runs do |t|
      t.integer :user_id
      t.integer :project_id
      t.string :expression
      t.integer :runtime_ms
      t.integer :subjects_count, null: false, default: 0
      t.integer :sheets_count, null: false, default: 0
      t.timestamps
      t.index :user_id
      t.index :project_id
      t.index :runtime_ms
      t.index :subjects_count
      t.index :sheets_count
    end
  end
end
