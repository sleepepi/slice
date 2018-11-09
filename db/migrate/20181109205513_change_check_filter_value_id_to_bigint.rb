class ChangeCheckFilterValueIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :check_filter_values, :id, :bigint
  end

  def down
    change_column :check_filter_values, :id, :integer
  end
end
