class AddHideValuesOnPdfsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :hide_values_on_pdfs, :boolean, null: false, default: false
  end
end
