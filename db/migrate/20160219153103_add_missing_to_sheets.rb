class AddMissingToSheets < ActiveRecord::Migration
  def change
    add_column :sheets, :missing, :boolean, null: false, default: false
    add_index :sheets, :missing
  end
end
