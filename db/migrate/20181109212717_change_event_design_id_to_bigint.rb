class ChangeEventDesignIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :event_designs, :id, :bigint
  end

  def down
    change_column :event_designs, :id, :integer
  end
end
