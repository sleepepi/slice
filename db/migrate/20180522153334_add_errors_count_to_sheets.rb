class AddErrorsCountToSheets < ActiveRecord::Migration[5.2]
  def change
    add_column :sheets, :errors_count, :integer, null: false, default: 0
    add_index :sheets, :errors_count
  end
end
