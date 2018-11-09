class DropAuditsTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :audits do |t|
      t.integer :auditable_id
      t.string :auditable_type
      t.integer :associated_id
      t.string :associated_type
      t.bigint :user_id
      t.string :user_type
      t.string :username
      t.string :action
      t.text :audited_changes
      t.integer :version, default: 0
      t.string :comment
      t.string :remote_address
      t.datetime :created_at

      t.index [:auditable_id, :auditable_type], name: "auditable_index"
      t.index [:associated_id, :associated_type], name: "associated_index"
      t.index [:user_id, :user_type], name: "user_index"
      t.index :created_at
    end
  end
end
