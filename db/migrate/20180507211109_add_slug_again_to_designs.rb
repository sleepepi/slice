class AddSlugAgainToDesigns < ActiveRecord::Migration[5.2]
  def change
    add_column :designs, :slug, :string
    add_index :designs, [:project_id, :slug], unique: true
  end
end
