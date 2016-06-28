class AddPositionToSchedules < ActiveRecord::Migration[4.2]
  def change
    add_column :schedules, :position, :integer, null: false, default: 0
  end
end
