class AddExpressionToChecks < ActiveRecord::Migration[5.2]
  def change
    add_column :checks, :expression, :text
  end
end
