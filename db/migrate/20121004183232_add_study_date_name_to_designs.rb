class AddStudyDateNameToDesigns < ActiveRecord::Migration
  def change
    add_column :designs, :study_date_name, :string
  end
end
