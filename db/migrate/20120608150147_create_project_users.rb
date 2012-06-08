class CreateProjectUsers < ActiveRecord::Migration
  def change
    create_table :project_users do |t|
      t.integer :project_id
      t.integer :user_id
      t.boolean :librarian, null: false, default: false

      t.timestamps
    end
  end
end
