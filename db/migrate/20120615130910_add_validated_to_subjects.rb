class AddValidatedToSubjects < ActiveRecord::Migration[4.2]
  def change
    add_column :subjects, :validated, :boolean, null: false, default: false
  end
end
