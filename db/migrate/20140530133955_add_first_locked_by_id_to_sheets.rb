class AddFirstLockedByIdToSheets < ActiveRecord::Migration[4.2]
  def change
    add_column :sheets, :first_locked_by_id, :integer
  end
end
