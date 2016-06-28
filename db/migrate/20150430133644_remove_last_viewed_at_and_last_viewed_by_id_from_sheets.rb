class RemoveLastViewedAtAndLastViewedByIdFromSheets < ActiveRecord::Migration[4.2]
  def up
    remove_index :sheets, :last_viewed_by_id

    remove_column :sheets, :last_viewed_by_id, :integer
    remove_column :sheets, :last_viewed_at, :datetime
  end

  def down
    add_column :sheets, :last_viewed_by_id, :integer
    add_column :sheets, :last_viewed_at, :datetime

    add_index :sheets, :last_viewed_by_id
  end

end
