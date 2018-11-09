class ChangeCubeIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :faces, :cube_id, :bigint
  end

  def down
    change_column :faces, :cube_id, :integer
  end
end
