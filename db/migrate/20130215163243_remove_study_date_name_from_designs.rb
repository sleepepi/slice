class RemoveStudyDateNameFromDesigns < ActiveRecord::Migration[4.2]
  def up
    remove_column :designs, :study_date_name
  end

  def down
    add_column :designs, :study_date_name, :string
  end
end
