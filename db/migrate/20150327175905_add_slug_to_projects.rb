class AddSlugToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :slug, :string
  end
end
