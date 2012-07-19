class AddAcrosticToSubjects < ActiveRecord::Migration
  def change
    add_column :subjects, :acrostic, :string, null: false, default: ''
  end
end
