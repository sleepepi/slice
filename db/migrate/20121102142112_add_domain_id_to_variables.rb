class AddDomainIdToVariables < ActiveRecord::Migration
  def change
    add_column :variables, :domain_id, :integer
    add_index :variables, :domain_id
  end
end
