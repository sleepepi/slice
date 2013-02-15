class RemoveStudyDateFromSheets < ActiveRecord::Migration
  def up
    remove_column :sheets, :study_date
  end

  def down
    add_column :sheets, :study_date, :date
  end
end
