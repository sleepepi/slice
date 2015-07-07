class CreateStratificationFactors < ActiveRecord::Migration
  def change
    create_table :stratification_factors do |t|
      t.integer :project_id
      t.integer :randomization_scheme_id
      t.integer :user_id
      t.string :name
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end

    add_index :stratification_factors, :project_id
    add_index :stratification_factors, :randomization_scheme_id
    add_index :stratification_factors, :user_id
    add_index :stratification_factors, :deleted
    add_index :stratification_factors, [:randomization_scheme_id, :deleted], name: 'index_sf_on_randomization_scheme_id_and_deleted'
  end
end
