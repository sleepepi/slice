class AddUnlockedAtToSheets < ActiveRecord::Migration[4.2]
  def change
    add_column :sheets, :unlocked_at, :datetime
  end
end
