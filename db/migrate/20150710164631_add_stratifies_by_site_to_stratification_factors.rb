class AddStratifiesBySiteToStratificationFactors < ActiveRecord::Migration
  def change
    add_column :stratification_factors, :stratifies_by_site, :boolean, null: false, default: false
  end
end
