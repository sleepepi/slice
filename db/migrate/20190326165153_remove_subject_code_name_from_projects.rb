class RemoveSubjectCodeNameFromProjects < ActiveRecord::Migration[6.0]
  def change
    remove_column :projects, :subject_code_name, :string
  end
end
