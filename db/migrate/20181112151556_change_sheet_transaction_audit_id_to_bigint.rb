class ChangeSheetTransactionAuditIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :sheet_transaction_audits, :id, :bigint
  end

  def down
    change_column :sheet_transaction_audits, :id, :integer
  end
end
