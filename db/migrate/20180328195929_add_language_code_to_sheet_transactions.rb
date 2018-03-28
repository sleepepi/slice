class AddLanguageCodeToSheetTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :sheet_transactions, :language_code, :string
  end
end
