class CreateAeDesignments < ActiveRecord::Migration[5.2]
  def change
    create_table :ae_designments do |t|
      t.bigint :project_id
      t.bigint :design_id
      t.bigint :ae_review_team_id
      t.bigint :ae_team_pathway_id
      t.integer :position
      t.timestamps

      t.index :project_id
      t.index :design_id
      t.index :ae_review_team_id
      t.index :ae_team_pathway_id
      t.index :position
    end
  end
end
