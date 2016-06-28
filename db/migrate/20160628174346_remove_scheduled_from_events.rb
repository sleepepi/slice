class RemoveScheduledFromEvents < ActiveRecord::Migration[4.2]
  def up
    remove_column :events, :scheduled
  end

  def down
    add_column :events, :scheduled, :boolean, null: false, default: true
  end
end
