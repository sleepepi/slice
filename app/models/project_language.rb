# frozen_string_literal: true

# Specify which languages are available for translation on project.
class ProjectLanguage < ApplicationRecord
  # Validations
  validates :language_code, uniqueness: { scope: :project_id }

  # Relationships
  belongs_to :project
end
