class AddLogoToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :logo, :string
    add_column :projects, :logo_uploaded_at, :datetime
  end
end
