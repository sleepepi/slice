class AddScaleTypeToVariables < ActiveRecord::Migration[4.2]
  def change
    add_column :variables, :scale_type, :string, null: false, default: 'radio'
  end
end
