class AddScaleTypeToVariables < ActiveRecord::Migration
  def change
    add_column :variables, :scale_type, :string, null: false, default: 'radio'
  end
end
