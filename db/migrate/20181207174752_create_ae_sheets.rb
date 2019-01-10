class CreateAeSheets < ActiveRecord::Migration[5.2]
  def change
    create_table :ae_sheets do |t|
      t.bigint :project_id
      t.bigint :ae_adverse_event_id
      t.bigint :sheet_id
      t.string :role
      t.bigint :ae_team_id
      t.bigint :ae_assignment_id
      t.timestamps

      t.index :project_id
      t.index [:ae_adverse_event_id, :sheet_id], unique: true
      t.index :role
      t.index :ae_team_id
      t.index :ae_assignment_id
    end
  end
end
