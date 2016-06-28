class AddAcrosticToSubjects < ActiveRecord::Migration[4.2]
  def change
    add_column :subjects, :acrostic, :string, null: false, default: ''
  end
end
