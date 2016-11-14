class CreateStatusChecks < ActiveRecord::Migration[5.0]
  def change
    create_table :status_checks do |t|
      t.integer :check_id
      t.integer :sheet_id
      t.boolean :failed
      t.index [:check_id, :sheet_id], unique: true
      t.index :failed
      t.timestamps
    end
  end
end
