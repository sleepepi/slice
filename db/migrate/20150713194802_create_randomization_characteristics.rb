class CreateRandomizationCharacteristics < ActiveRecord::Migration
  def change
    create_table :randomization_characteristics do |t|
      t.integer :project_id
      t.integer :randomization_scheme_id
      t.integer :list_id
      t.integer :randomization_id
      t.integer :stratification_factor_id
      t.integer :stratification_factor_option_id
      t.integer :site_id

      t.timestamps null: false
    end

    add_index :randomization_characteristics, :project_id
    add_index :randomization_characteristics, :randomization_scheme_id
    add_index :randomization_characteristics, :list_id
    add_index :randomization_characteristics, :randomization_id
    add_index :randomization_characteristics, :stratification_factor_id
    add_index :randomization_characteristics, :stratification_factor_option_id, name: 'index_rc_on_stratification_factor_id'
    add_index :randomization_characteristics, :site_id
  end
end
