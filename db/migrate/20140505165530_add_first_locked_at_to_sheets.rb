class AddFirstLockedAtToSheets < ActiveRecord::Migration
  def change
    add_column :sheets, :first_locked_at, :datetime
  end
end
