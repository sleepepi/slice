class AddAuthenticationTokenToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :authentication_token, :string
    add_index  :projects, :authentication_token, unique: true
  end
end
