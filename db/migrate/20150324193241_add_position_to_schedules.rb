class AddPositionToSchedules < ActiveRecord::Migration
  def change
    add_column :schedules, :position, :integer, null: false, default: 0
  end
end
