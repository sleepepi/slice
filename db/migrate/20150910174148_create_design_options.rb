class CreateDesignOptions < ActiveRecord::Migration[4.2]
  def change
    create_table :design_options do |t|
      t.integer :design_id
      t.integer :variable_id
      t.integer :section_id
      t.integer :position, null: false, default: 0
      t.string :required
      t.text :branching_logic

      t.timestamps null: false
    end

    add_index :design_options, :design_id
    add_index :design_options, :variable_id
    add_index :design_options, :section_id
    add_index :design_options, [:design_id, :variable_id], unique: true
    add_index :design_options, [:design_id, :section_id], unique: true
  end
end
