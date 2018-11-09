class ChangeAdverseEventCommentIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :adverse_event_comments, :id, :bigint
  end

  def down
    change_column :adverse_event_comments, :id, :integer
  end
end
