class CreateProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :profiles do |t|
      t.string :username
      t.string :description
      t.integer :user_id
      t.integer :organization_id
      t.timestamps
      t.index :username, unique: true
      t.index :user_id, unique: true
      t.index :organization_id, unique: true
    end
  end
end
