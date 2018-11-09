class ChangeResponseIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :responses, :id, :bigint
  end

  def down
    change_column :responses, :id, :integer
  end
end
