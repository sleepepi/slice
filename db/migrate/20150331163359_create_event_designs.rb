class CreateEventDesigns < ActiveRecord::Migration[4.2]
  def change
    create_table :event_designs do |t|
      t.integer :event_id
      t.integer :design_id
      t.integer :position, null: false, default: 0

      t.timestamps null: false
    end

    add_index :event_designs, :event_id
    add_index :event_designs, :design_id
  end
end
