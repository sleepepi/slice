class AddStatusToSubjects < ActiveRecord::Migration
  def change
    add_column :subjects, :status, :string, null: false, default: 'pending'
  end
end
