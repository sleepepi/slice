class AddCommentsCountToSheets < ActiveRecord::Migration[5.1]
  def change
    add_column :sheets, :comments_count, :integer, null: false, default: 0
    add_index :sheets, :comments_count
  end
end
