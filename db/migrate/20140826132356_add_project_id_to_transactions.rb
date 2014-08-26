class AddProjectIdToTransactions < ActiveRecord::Migration
  def change
    add_column :sheet_transactions, :project_id, :integer
    add_column :sheet_transaction_audits, :project_id, :integer
    add_index :sheet_transactions, :project_id
    add_index :sheet_transaction_audits, :project_id
  end
end
