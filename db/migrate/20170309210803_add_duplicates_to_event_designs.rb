class AddDuplicatesToEventDesigns < ActiveRecord::Migration[5.0]
  def change
    add_column :event_designs, :duplicates, :string, null: false, default: 'highlight'
  end
end
