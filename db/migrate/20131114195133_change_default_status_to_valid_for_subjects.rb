class ChangeDefaultStatusToValidForSubjects < ActiveRecord::Migration
  def up
    change_column :subjects, :status, :string, null: false, default: 'valid'
    Subject.where( status: 'pending' ).update_all( status: 'valid' )
  end

  def down
    change_column :subjects, :status, :string, null: false, default: 'pending'
  end
end
