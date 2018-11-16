class CreateAeReviewTeamMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :ae_review_team_members do |t|
      t.bigint :project_id
      t.bigint :ae_review_team_id
      t.bigint :user_id
      t.boolean :manager, null: false, default: false
      t.boolean :reviewer, null: false, default: false
      t.boolean :viewer, null: false, default: false
      t.timestamps
      t.index [:project_id]
      t.index [:ae_review_team_id, :user_id], unique: true
      t.index :manager
      t.index :reviewer
      t.index :viewer
    end
  end
end
