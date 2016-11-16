class CreateDomainOptions < ActiveRecord::Migration[5.0]
  def change
    create_table :domain_options do |t|
      t.integer :domain_id
      t.string :name
      t.string :value
      t.text :description
      t.integer :site_id
      t.boolean :missing_code, null: false, default: false
      t.boolean :archived, null: false, default: false
      t.integer :position
      t.timestamps
      t.index [:domain_id, :value], unique: true
      t.index [:missing_code]
      t.index [:site_id]
      t.index [:archived]
      t.index :position
    end
  end
end
