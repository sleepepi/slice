class ChangeRandomizationCharacteristicIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :randomization_characteristics, :id, :bigint
  end

  def down
    change_column :randomization_characteristics, :id, :integer
  end
end
