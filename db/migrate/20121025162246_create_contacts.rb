class CreateContacts < ActiveRecord::Migration
  def change
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

      t.timestamps
    end
  end
end
