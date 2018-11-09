class ChangeCommentIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :comments, :id, :bigint
    change_column :notifications, :comment_id, :bigint
  end

  def down
    change_column :comments, :id, :integer
    change_column :notifications, :comment_id, :integer
  end
end
