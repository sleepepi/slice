class AddStudyDateNameToDesigns < ActiveRecord::Migration[4.2]
  def change
    add_column :designs, :study_date_name, :string
  end
end
