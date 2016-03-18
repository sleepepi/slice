class AddUnlockedAtToSheets < ActiveRecord::Migration
  def change
    add_column :sheets, :unlocked_at, :datetime
  end
end
