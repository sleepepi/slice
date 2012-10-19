class AddLastViewedByIdToSheets < ActiveRecord::Migration
  def change
    add_column :sheets, :last_viewed_by_id, :integer
    add_column :sheets, :last_viewed_at, :datetime

    add_index :sheets, :last_viewed_by_id
  end
end
