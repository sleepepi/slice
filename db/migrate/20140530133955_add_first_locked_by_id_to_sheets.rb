class AddFirstLockedByIdToSheets < ActiveRecord::Migration
  def change
    add_column :sheets, :first_locked_by_id, :integer
  end
end
