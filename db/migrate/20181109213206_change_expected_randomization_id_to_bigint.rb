class ChangeExpectedRandomizationIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :expected_randomizations, :id, :bigint
  end

  def down
    change_column :expected_randomizations, :id, :integer
  end
end
