class CreateSheetUnlockRequests < ActiveRecord::Migration
  def change
    create_table :sheet_unlock_requests do |t|
      t.integer :sheet_id
      t.integer :user_id
      t.text :reason
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end

    add_index :sheet_unlock_requests, :sheet_id
    add_index :sheet_unlock_requests, :user_id
    add_index :sheet_unlock_requests, :deleted
  end
end
