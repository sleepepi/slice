class AddEmailToSubjects < ActiveRecord::Migration
  def change
    add_column :subjects, :email, :string
  end
end
