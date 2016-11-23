class AddPercentToSheets < ActiveRecord::Migration[5.0]
  def change
    add_column :sheets, :percent, :integer
    add_index :sheets, :percent
  end
end
