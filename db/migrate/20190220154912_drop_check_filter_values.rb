class DropCheckFilterValues < ActiveRecord::Migration[6.0]
  def change
    drop_table :check_filter_values do |t|
      t.bigint :project_id
      t.bigint :user_id
      t.bigint :check_id
      t.bigint :check_filter_id
      t.string :value
      t.timestamps
      t.index :project_id
      t.index :user_id
      t.index :check_id
      t.index :check_filter_id
    end
  end
end
