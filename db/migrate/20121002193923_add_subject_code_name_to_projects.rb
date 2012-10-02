class AddSubjectCodeNameToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :subject_code_name, :string
  end
end
