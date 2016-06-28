class RemoveReports < ActiveRecord::Migration[4.2]
  def up
    drop_table :reports
  end

  def down
    create_table :reports do |t|
      t.integer :user_id
      t.string :name
      t.text :options
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end
  end
end
