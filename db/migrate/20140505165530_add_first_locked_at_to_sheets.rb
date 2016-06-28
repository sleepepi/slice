class AddFirstLockedAtToSheets < ActiveRecord::Migration[4.2]
  def change
    add_column :sheets, :first_locked_at, :datetime
  end
end
