class DropAeTeamPathwayDesigns < ActiveRecord::Migration[5.2]
  def change
    drop_table :ae_team_pathway_designs do |t|
      t.bigint :ae_team_pathway_id
      t.bigint :design_id
      t.integer :position
      t.timestamps
      t.index [:ae_team_pathway_id, :design_id], unique: true, name: "idx_pathway_design"
      t.index :position
    end
  end
end
