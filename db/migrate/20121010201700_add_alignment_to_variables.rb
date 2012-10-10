class AddAlignmentToVariables < ActiveRecord::Migration
  def change
    add_column :variables, :alignment, :string, null: false, default: 'vertical'
  end
end
