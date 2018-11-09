class ChangeCheckFilterIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :check_filters, :id, :bigint
    change_column :check_filter_values, :check_filter_id, :bigint
  end

  def down
    change_column :check_filters, :id, :integer
    change_column :check_filter_values, :check_filter_id, :integer
  end
end
