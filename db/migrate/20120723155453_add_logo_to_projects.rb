class AddLogoToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :logo, :string
    add_column :projects, :logo_uploaded_at, :datetime
  end
end
