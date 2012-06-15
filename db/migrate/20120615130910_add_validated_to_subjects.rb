class AddValidatedToSubjects < ActiveRecord::Migration
  def change
    add_column :subjects, :validated, :boolean, null: false, default: false
  end
end
