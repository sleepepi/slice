class CreateInvites < ActiveRecord::Migration[5.2]
  def change
    create_table :invites do |t|
      t.bigint :project_id
      t.bigint :inviter_id
      t.string :email
      t.string :role
      t.string :subgroup_type
      t.bigint :subgroup_id
      t.datetime :email_sent_at
      t.datetime :accepted_at
      t.datetime :declined_at
      t.timestamps
      t.index :project_id
      t.index :inviter_id
      t.index :email
      t.index :subgroup_type
      t.index :subgroup_id
      t.index :accepted_at
      t.index :declined_at
    end
  end
end
