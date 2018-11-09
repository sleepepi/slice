class ChangeAdverseEventReviewIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :adverse_event_reviews, :id, :bigint
  end

  def down
    change_column :adverse_event_reviews, :id, :integer
  end
end
