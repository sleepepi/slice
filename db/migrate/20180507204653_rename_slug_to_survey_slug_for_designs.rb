class RenameSlugToSurveySlugForDesigns < ActiveRecord::Migration[5.2]
  def change
    rename_column :designs, :slug, :survey_slug
  end
end
