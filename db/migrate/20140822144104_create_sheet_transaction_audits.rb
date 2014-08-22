class CreateSheetTransactionAudits < ActiveRecord::Migration
  def change
    create_table :sheet_transaction_audits do |t|
      t.integer :sheet_transaction_id
      t.integer :user_id
      t.integer :sheet_id
      t.integer :sheet_variable_id
      t.integer :grid_id
      t.string :sheet_attribute_name
      t.text :value_before
      t.text :label_before
      t.text :value_after
      t.text :label_after
      t.boolean :value_for_file, null: false, default: false
      t.datetime :created_at, null: false
    end

    add_index :sheet_transaction_audits, :sheet_transaction_id
    add_index :sheet_transaction_audits, :user_id
    add_index :sheet_transaction_audits, :sheet_id
    add_index :sheet_transaction_audits, :sheet_variable_id
    add_index :sheet_transaction_audits, :grid_id
  end
end
