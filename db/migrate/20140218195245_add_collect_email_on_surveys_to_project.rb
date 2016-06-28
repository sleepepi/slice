class AddCollectEmailOnSurveysToProject < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :collect_email_on_surveys, :boolean, null: false, default: true
  end
end
