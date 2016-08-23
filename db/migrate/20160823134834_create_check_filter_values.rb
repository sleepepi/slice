class CreateCheckFilterValues < ActiveRecord::Migration[5.0]
  def change
    create_table :check_filter_values do |t|
      t.integer :project_id
      t.integer :user_id
      t.integer :check_id
      t.integer :check_filter_id
      t.string :value
      t.timestamps
      t.index :project_id
      t.index :user_id
      t.index :check_id
      t.index :check_filter_id
    end
  end
end
