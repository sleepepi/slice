class ChangeGridIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :grids, :id, :bigint

    change_column :responses, :grid_id, :bigint
    change_column :sheet_transaction_audits, :grid_id, :bigint
  end

  def down
    change_column :grids, :id, :integer

    change_column :responses, :grid_id, :integer
    change_column :sheet_transaction_audits, :grid_id, :integer
  end
end
