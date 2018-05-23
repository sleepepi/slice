class CreateSheetErrors < ActiveRecord::Migration[5.2]
  def change
    create_table :sheet_errors do |t|
      t.integer :project_id
      t.integer :sheet_id
      t.text :description
      t.timestamps
      t.index :project_id
      t.index :sheet_id
    end
  end
end
