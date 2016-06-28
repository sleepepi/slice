class CreateSections < ActiveRecord::Migration[4.2]
  def change
    create_table :sections do |t|
      t.string :name
      t.text :description
      t.boolean :sub_section, null: false, default: false
      t.text :branching_logic
      t.string :image
      t.integer :project_id
      t.integer :design_id
      t.integer :user_id

      t.timestamps
    end
  end
end
