class ChangeDesignPrintIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :design_prints, :id, :bigint
  end

  def down
    change_column :design_prints, :id, :integer
  end
end
