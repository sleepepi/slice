class CreateOldPasswords < ActiveRecord::Migration
  def change
    create_table :old_passwords do |t|
      t.integer :user_id
      t.string :encrypted_password

      t.timestamps null: false
    end

    add_index :old_passwords, :user_id
  end
end
