class CreateAeReviewGroupSheets < ActiveRecord::Migration[5.2]
  def change
    create_table :ae_review_group_sheets do |t|
      t.bigint :project_id
      t.bigint :ae_review_group_id
      t.bigint :sheet_id
      t.timestamps
      t.index :project_id
      t.index [:ae_review_group_id, :sheet_id], unique: true
    end
  end
end
