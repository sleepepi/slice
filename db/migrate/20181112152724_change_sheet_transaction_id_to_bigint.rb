class ChangeSheetTransactionIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :sheet_transactions, :id, :bigint

    change_column :sheet_transaction_audits, :sheet_transaction_id, :bigint
  end

  def down
    change_column :sheet_transactions, :id, :integer

    change_column :sheet_transaction_audits, :sheet_transaction_id, :integer
  end
end
