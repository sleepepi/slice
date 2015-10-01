class CreateAdverseEventUsers < ActiveRecord::Migration
  def change
    create_table :adverse_event_users do |t|
      t.integer :adverse_event_id
      t.integer :user_id
      t.datetime :last_viewed_at
    end

    add_index :adverse_event_users, [:adverse_event_id, :user_id], unique: true
  end
end
