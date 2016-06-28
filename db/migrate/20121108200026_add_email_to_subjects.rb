class AddEmailToSubjects < ActiveRecord::Migration[4.2]
  def change
    add_column :subjects, :email, :string
  end
end
