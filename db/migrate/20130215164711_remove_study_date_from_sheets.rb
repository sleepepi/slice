class RemoveStudyDateFromSheets < ActiveRecord::Migration[4.2]
  def up
    remove_column :sheets, :study_date
  end

  def down
    add_column :sheets, :study_date, :date
  end
end
