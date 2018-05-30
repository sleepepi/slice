class AddProfilePictureToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :profile_picture, :string
  end
end
