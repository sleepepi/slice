class ChangeOldPasswordIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :old_passwords, :id, :bigint
  end

  def down
    change_column :old_passwords, :id, :integer
  end
end
