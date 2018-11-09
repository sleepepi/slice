class ChangeBlockSizeMultiplierIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :block_size_multipliers, :id, :bigint
  end

  def down
    change_column :block_size_multipliers, :id, :integer
  end
end
