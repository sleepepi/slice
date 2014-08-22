class CreateSheetTransactions < ActiveRecord::Migration
  def change
    create_table :sheet_transactions do |t|
      t.string :transaction_type
      t.integer :sheet_id
      t.integer :user_id
      t.string :remote_ip
      t.datetime :created_at, null: false
    end

    add_index :sheet_transactions, :sheet_id
    add_index :sheet_transactions, :user_id
  end
end
