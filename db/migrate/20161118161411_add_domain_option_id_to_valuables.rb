class AddDomainOptionIdToValuables < ActiveRecord::Migration[5.0]
  def change
    add_column :sheet_variables, :domain_option_id, :integer
    add_column :grids, :domain_option_id, :integer
    add_column :responses, :domain_option_id, :integer
    add_index :sheet_variables, :domain_option_id
    add_index :grids, :domain_option_id
    add_index :responses, :domain_option_id
  end
end
