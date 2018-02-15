# frozen_string_literal: true

# Captures a users preferences for a project, pinned vs archived, emails enabled
# vs disabled.
class ProjectPreference < ApplicationRecord
  # Validations
  validates :user_id, uniqueness: { scope: :project_id }

  # Relationships
  belongs_to :project
  belongs_to :user
end
