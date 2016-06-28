class AddSlugToDesigns < ActiveRecord::Migration[4.2]
  def change
    add_column :designs, :slug, :string
  end
end
