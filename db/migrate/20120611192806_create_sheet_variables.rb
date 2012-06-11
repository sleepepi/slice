class CreateSheetVariables < ActiveRecord::Migration
  def change
    create_table :sheet_variables do |t|
      t.integer :variable_id
      t.integer :sheet_id
      t.text :response
      t.integer :user_id

      t.timestamps
    end
  end
end
