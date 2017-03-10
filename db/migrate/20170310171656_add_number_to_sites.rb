class AddNumberToSites < ActiveRecord::Migration[5.0]
  def change
    add_column :sites, :number, :integer
    add_index :sites, [:number, :project_id], unique: true
  end
end
