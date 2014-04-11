class AddLockedToSheets < ActiveRecord::Migration
  def change
    add_column :sheets, :locked, :boolean, null: false, default: false
  end
end
