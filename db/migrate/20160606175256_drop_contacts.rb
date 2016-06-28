class DropContacts < ActiveRecord::Migration[4.2]
  def up
    remove_column :projects, :show_contacts
    drop_table :contacts
  end

  def down
    create_table :contacts do |t|
      t.string :title
      t.string :name
      t.string :phone
      t.string :fax
      t.string :email
      t.integer :position, null: false, default: 0
      t.integer :user_id
      t.integer :project_id
      t.boolean :deleted, null: false, default: false
      t.boolean :archived, null: false, default: false
      t.timestamps
    end
    add_column :projects, :show_contacts, :boolean, null: false, default: true
  end
end
