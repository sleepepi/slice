class AddSlugToDesigns < ActiveRecord::Migration
  def change
    add_column :designs, :slug, :string
  end
end
