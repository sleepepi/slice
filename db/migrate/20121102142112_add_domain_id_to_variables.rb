class AddDomainIdToVariables < ActiveRecord::Migration[4.2]
  def change
    add_column :variables, :domain_id, :integer
    add_index :variables, :domain_id
  end
end
