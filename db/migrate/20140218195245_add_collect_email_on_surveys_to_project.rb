class AddCollectEmailOnSurveysToProject < ActiveRecord::Migration
  def change
    add_column :projects, :collect_email_on_surveys, :boolean, null: false, default: true
  end
end
