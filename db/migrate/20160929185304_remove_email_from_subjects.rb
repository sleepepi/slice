class RemoveEmailFromSubjects < ActiveRecord::Migration[5.0]
  def change
    remove_column :subjects, :email, :string
  end
end
