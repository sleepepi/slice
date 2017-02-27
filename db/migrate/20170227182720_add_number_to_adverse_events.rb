class AddNumberToAdverseEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :adverse_events, :number, :integer
    add_index :adverse_events, :number
  end
end
