class AddTotalStepsToExports < ActiveRecord::Migration
  def change
    add_column :exports, :steps_completed, :integer, null: false, default: 0
    add_column :exports, :total_steps, :integer, null: false, default: 0
    add_column :exports, :sheet_ids_count, :integer, null: false, default: 0
  end
end
