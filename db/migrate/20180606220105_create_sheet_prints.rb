class CreateSheetPrints < ActiveRecord::Migration[5.2]
  def change
    create_table :sheet_prints do |t|
      t.integer :sheet_id
      t.string :language
      t.boolean :outdated, null: false, default: true
      t.string :file
      t.bigint :file_size, null: false, default: 0
      t.timestamps
      t.index [:sheet_id, :language], unique: true
    end
  end
end
