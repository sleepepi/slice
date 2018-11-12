class ChangeStatusCheckIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :status_checks, :id, :bigint
  end

  def down
    change_column :status_checks, :id, :integer
  end
end
