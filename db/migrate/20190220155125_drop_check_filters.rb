class DropCheckFilters < ActiveRecord::Migration[6.0]
  def change
    drop_table :check_filters do |t|
      t.bigint :project_id
      t.bigint :user_id
      t.bigint :check_id
      t.string :filter_type, null: false, default: "variable"
      t.bigint :variable_id
      t.string :operator, null: false, default: "eq"
      t.integer :position, null: false, default: 0
      t.timestamps
      t.index :project_id
      t.index :user_id
      t.index :check_id
      t.index :variable_id
      t.index :position
    end
  end
end
