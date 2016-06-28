class CreateReports < ActiveRecord::Migration[4.2]
  def change
    create_table :reports do |t|
      t.integer :user_id
      t.string :name
      t.text :options
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end
