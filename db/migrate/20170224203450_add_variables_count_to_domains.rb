class AddVariablesCountToDomains < ActiveRecord::Migration[5.0]
  def change
    add_column :domains, :variables_count, :integer, null: false, default: 0
  end
end
