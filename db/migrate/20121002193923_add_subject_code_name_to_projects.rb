class AddSubjectCodeNameToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :subject_code_name, :string
  end
end
