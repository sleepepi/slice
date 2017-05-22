class AddFileSizeToExports < ActiveRecord::Migration[5.1]
  def change
    add_column :exports, :file_size, :bigint, null: false, default: 0
    add_index :exports, :file_size
  end
end
