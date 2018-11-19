class CreateAeTeamPathways < ActiveRecord::Migration[5.2]
  def change
    create_table :ae_team_pathways do |t|
      t.bigint :project_id
      t.bigint :ae_review_team_id
      t.string :name
      t.integer :number_of_reviewers, null: false, default: 0
      t.boolean :deleted, null: false, default: false
      t.timestamps
      t.index :project_id
      t.index :ae_review_team_id
      t.index :deleted
    end
  end
end
