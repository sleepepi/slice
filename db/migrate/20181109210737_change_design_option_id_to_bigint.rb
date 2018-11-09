class ChangeDesignOptionIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :design_options, :id, :bigint
  end

  def down
    change_column :design_options, :id, :integer
  end
end
