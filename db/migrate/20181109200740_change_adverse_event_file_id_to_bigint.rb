class ChangeAdverseEventFileIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :adverse_event_files, :id, :bigint
  end

  def down
    change_column :adverse_event_files, :id, :integer
  end
end
