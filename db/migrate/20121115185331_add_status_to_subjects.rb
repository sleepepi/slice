class AddStatusToSubjects < ActiveRecord::Migration[4.2]
  def change
    add_column :subjects, :status, :string, null: false, default: 'pending'
  end
end
