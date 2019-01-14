class CreateAeLogEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :ae_log_entries do |t|
      t.bigint :project_id
      t.bigint :ae_adverse_event_id
      t.bigint :user_id
      t.bigint :ae_team_id
      t.string :entry_type
      t.timestamps
      t.index :project_id
      t.index :ae_adverse_event_id
      t.index :user_id
      t.index :ae_team_id
    end
  end
end
