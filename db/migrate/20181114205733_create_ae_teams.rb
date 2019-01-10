class CreateAeTeams < ActiveRecord::Migration[5.2]
  def change
    create_table :ae_teams do |t|
      t.bigint :project_id
      t.string :name
      t.string :slug
      t.boolean :deleted, null: false, default: false
      t.timestamps
      t.index [:project_id, :slug], unique: true
      t.index :deleted
    end
  end
end
