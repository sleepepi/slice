class CreateStratificationFactorOptions < ActiveRecord::Migration
  def change
    create_table :stratification_factor_options do |t|
      t.integer :project_id
      t.integer :randomization_scheme_id
      t.integer :stratification_factor_id
      t.integer :user_id
      t.string :label
      t.integer :value, null: false, default: 0
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end

    add_index :stratification_factor_options, :project_id
    add_index :stratification_factor_options, :randomization_scheme_id
    add_index :stratification_factor_options, :stratification_factor_id
    add_index :stratification_factor_options, :user_id
    add_index :stratification_factor_options, :deleted
    add_index :stratification_factor_options, [:stratification_factor_id, :deleted], name: 'index_sfo_on_stratification_factor_id_and_deleted'
  end
end
