class CreateExpectedRandomizations < ActiveRecord::Migration
  def change
    create_table :expected_randomizations do |t|
      t.integer :randomization_scheme_id
      t.integer :site_id
      t.string :expected

      t.timestamps null: false
    end

    add_index :expected_randomizations, [:randomization_scheme_id, :site_id],
              unique: true, name: 'expected_randomizations_index'
  end
end
