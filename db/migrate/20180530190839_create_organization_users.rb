class CreateOrganizationUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :organization_users do |t|
      t.integer :organization_id
      t.integer :user_id
      t.timestamps
      t.index [:organization_id, :user_id], unique: true
    end
  end
end
