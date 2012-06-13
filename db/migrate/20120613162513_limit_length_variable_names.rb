class LimitLengthVariableNames < ActiveRecord::Migration
  def up
    change_column :variables, :name, :string, limit: 32
  end

  def down
    change_column :variables, :name, :string, limit: 255
  end
end
