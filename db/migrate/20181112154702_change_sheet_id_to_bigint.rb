class ChangeSheetIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :sheets, :id, :bigint

    change_column :comments, :sheet_id, :bigint
    change_column :notifications, :sheet_id, :bigint
    change_column :responses, :sheet_id, :bigint
    change_column :sheet_errors, :sheet_id, :bigint
    change_column :sheet_prints, :sheet_id, :bigint
    change_column :sheet_transaction_audits, :sheet_id, :bigint
    change_column :sheet_transactions, :sheet_id, :bigint
    change_column :sheet_unlock_requests, :sheet_id, :bigint
    change_column :sheet_variables, :sheet_id, :bigint
    change_column :status_checks, :sheet_id, :bigint
  end

  def down
    change_column :sheets, :id, :integer

    change_column :comments, :sheet_id, :integer
    change_column :notifications, :sheet_id, :integer
    change_column :responses, :sheet_id, :integer
    change_column :sheet_errors, :sheet_id, :integer
    change_column :sheet_prints, :sheet_id, :integer
    change_column :sheet_transaction_audits, :sheet_id, :integer
    change_column :sheet_transactions, :sheet_id, :integer
    change_column :sheet_unlock_requests, :sheet_id, :integer
    change_column :sheet_variables, :sheet_id, :integer
    change_column :status_checks, :sheet_id, :integer
  end
end
