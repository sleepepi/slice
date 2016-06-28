class AddStratifiesBySiteToStratificationFactors < ActiveRecord::Migration[4.2]
  def change
    add_column :stratification_factors, :stratifies_by_site, :boolean, null: false, default: false
  end
end
