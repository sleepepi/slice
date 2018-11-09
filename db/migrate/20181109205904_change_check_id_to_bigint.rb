class ChangeCheckIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :checks, :id, :bigint

    change_column :check_filter_values, :check_id, :bigint
    change_column :check_filters, :check_id, :bigint
    change_column :status_checks, :check_id, :bigint
  end

  def down
    change_column :checks, :id, :integer

    change_column :check_filter_values, :check_id, :integer
    change_column :check_filters, :check_id, :integer
    change_column :status_checks, :check_id, :integer
  end
end
