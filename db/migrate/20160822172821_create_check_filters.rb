class CreateCheckFilters < ActiveRecord::Migration[5.0]
  def change
    create_table :check_filters do |t|
      t.integer :project_id
      t.integer :user_id
      t.integer :check_id
      t.string :filter_type, null: false, default: 'variable'
      t.integer :variable_id
      t.string :operator, null: false, default: 'eq'
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
