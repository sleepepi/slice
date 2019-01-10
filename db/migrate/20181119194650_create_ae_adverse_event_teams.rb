class CreateAeAdverseEventTeams < ActiveRecord::Migration[5.2]
  def change
    create_table :ae_adverse_event_teams do |t|
      t.bigint :project_id
      t.bigint :ae_adverse_event_id
      t.bigint :ae_team_id
      t.timestamps
      t.index :project_id
      t.index [:ae_adverse_event_id, :ae_team_id], unique: true, name: "idx_adverse_event_team"
    end
  end
end
