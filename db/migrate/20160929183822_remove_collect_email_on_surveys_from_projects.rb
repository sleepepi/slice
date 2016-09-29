class RemoveCollectEmailOnSurveysFromProjects < ActiveRecord::Migration[5.0]
  def change
    remove_column :projects, :collect_email_on_surveys, :boolean, null: false, default: true
  end
end
