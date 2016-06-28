class DropDocuments < ActiveRecord::Migration[4.2]
  def up
    remove_column :projects, :show_documents
    drop_table :documents
  end

  def down
    create_table :documents do |t|
      t.string :name
      t.string :category
      t.string :file
      t.boolean :archived, null: false, default: false
      t.integer :user_id
      t.integer :project_id
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
    add_column :projects, :show_documents, :boolean, null: false, default: true
  end
end
