class ChangeListOptionIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :list_options, :id, :bigint
  end

  def down
    change_column :list_options, :id, :integer
  end
end
