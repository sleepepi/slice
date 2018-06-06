class AddLastRunAtToChecks < ActiveRecord::Migration[5.2]
  def change
    add_column :checks, :last_run_at, :datetime
    add_index :checks, :last_run_at
  end
end
