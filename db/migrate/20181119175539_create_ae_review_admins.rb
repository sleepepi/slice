class CreateAeReviewAdmins < ActiveRecord::Migration[5.2]
  def change
    create_table :ae_review_admins do |t|
      t.bigint :project_id
      t.bigint :user_id
      t.timestamps
      t.index [:project_id, :user_id], unique: true
    end
  end
end
