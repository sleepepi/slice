class CreateInvites < ActiveRecord::Migration[5.2]
  def change
    create_table :invites do |t|
      t.bigint :project_id
      t.bigint :inviter_id
      t.string :email
      t.string :invite_token
      t.string :role
      t.string :subgroup_type
      t.bigint :subgroup_id
      t.datetime :claimed_at
      t.timestamps
      t.index :project_id
      t.index :inviter_id
      t.index :email
      t.index :invite_token, unique: true
      t.index :subgroup_type
      t.index :subgroup_id
    end
  end
end
