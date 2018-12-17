class AddSentForReviewAtToAeAdverseEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :ae_adverse_events, :sent_for_review_at, :datetime
    add_index :ae_adverse_events, :sent_for_review_at
  end
end
