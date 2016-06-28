class AddMissingToSheets < ActiveRecord::Migration[4.2]
  def change
    add_column :sheets, :missing, :boolean, null: false, default: false
    add_index :sheets, :missing
  end
end
