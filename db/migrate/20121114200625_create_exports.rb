class CreateExports < ActiveRecord::Migration
  def change
    create_table :exports do |t|
      t.string :name
      t.string :export_type, null: false, default: 'sheets'
      t.boolean :include_files, null: false, default: false
      t.string :status, null: false, default: 'pending'
      t.string :file
      t.integer :user_id
      t.integer :project_id
      t.boolean :viewed, null: false, default: false
      t.boolean :deleted, null: false, default: false
      t.datetime :file_created_at

      t.timestamps
    end

    add_index :exports, :user_id
    add_index :exports, :project_id
  end
end
