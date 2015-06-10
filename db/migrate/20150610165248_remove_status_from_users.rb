class RemoveStatusFromUsers < ActiveRecord::Migration
  def up
    remove_index :users, :status
    remove_column :users, :status
  end

  def down
    add_column :users, :status, :string, null: false, default: 'pending'
    add_index :users, :status
  end
end
