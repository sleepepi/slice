class RemoveScheduledFromEvents < ActiveRecord::Migration
  def up
    remove_column :events, :scheduled
  end

  def down
    add_column :events, :scheduled, :boolean, null: false, default: true
  end
end
