class AddIndexForSurveySlug < ActiveRecord::Migration[5.2]
  def change
    add_index :designs, :survey_slug, unique: true
  end
end
