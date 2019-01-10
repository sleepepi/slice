class CreateAeInfoRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :ae_info_requests do |t|
      t.bigint :project_id
      t.bigint :ae_adverse_event_id
      t.bigint :user_id
      t.bigint :ae_team_id
      t.text :comment
      t.datetime :resolved_at
      t.bigint :resolver_id
      t.timestamps
      t.index :project_id
      t.index :ae_adverse_event_id
      t.index :user_id
      t.index :ae_team_id
      t.index :resolved_at
      t.index :resolver_id
    end
  end
end
