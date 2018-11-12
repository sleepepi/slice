class ChangeSheetVariableIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :sheet_variables, :id, :bigint

    change_column :grids, :sheet_variable_id, :bigint
    change_column :responses, :sheet_variable_id, :bigint
    change_column :sheet_transaction_audits, :sheet_variable_id, :bigint
  end

  def down
    change_column :sheet_variables, :id, :integer

    change_column :grids, :sheet_variable_id, :integer
    change_column :responses, :sheet_variable_id, :integer
    change_column :sheet_transaction_audits, :sheet_variable_id, :integer
  end
end
