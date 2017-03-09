class AddConditionalDesignTriggersToEventDesigns < ActiveRecord::Migration[5.0]
  def change
    add_column :event_designs, :requirement, :string, null: false, default: 'always'
    add_column :event_designs, :conditional_event_id, :integer
    add_column :event_designs, :conditional_design_id, :integer
    add_column :event_designs, :conditional_variable_id, :integer
    add_column :event_designs, :conditional_value, :string
    add_column :event_designs, :conditional_operator, :string, null: false, default: '='

    add_index :event_designs, :requirement
    add_index :event_designs, :conditional_event_id
    add_index :event_designs, :conditional_design_id
    add_index :event_designs, :conditional_variable_id
  end
end
