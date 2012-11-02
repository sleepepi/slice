class CreateDomains < ActiveRecord::Migration
  def change
    create_table :domains do |t|
      t.string :name
      t.text :description
      t.text :options
      t.integer :user_id
      t.integer :project_id
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end

    add_index :domains, :user_id
    add_index :domains, :project_id
  end
end
