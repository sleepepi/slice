class CreateTrayPrints < ActiveRecord::Migration[5.2]
  def change
    create_table :tray_prints do |t|
      t.integer :tray_id
      t.string :language
      t.boolean :outdated, null: false, default: true
      t.string :file
      t.bigint :file_size, null: false, default: 0
      t.timestamps
      t.index [:tray_id, :language], unique: true
    end
  end
end
