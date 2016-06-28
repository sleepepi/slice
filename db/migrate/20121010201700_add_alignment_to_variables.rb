class AddAlignmentToVariables < ActiveRecord::Migration[4.2]
  def change
    add_column :variables, :alignment, :string, null: false, default: 'vertical'
  end
end
