# frozen_string_literal: true

# Captures a users preferences for a project, favorited, archived, emails.
class ProjectPreference < ApplicationRecord
  # Model Validation
  validates :project_id, :user_id, presence: true
  validates :user_id, uniqueness: { scope: :project_id }

  # Model Relationships
  belongs_to :project
  belongs_to :user
end
