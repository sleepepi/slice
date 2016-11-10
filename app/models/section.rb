# frozen_string_literal: true

# Allows main sections, subsections, and warnings to be added to designs
class Section < ApplicationRecord
  # Constants
  LEVELS = [
    ['Section', 0],
    ['Subsection', 1],
    ['Informational', 2],
    ['Warning', 3],
    ['Alert', 4]
  ]

  # Uploaders
  mount_uploader :image, ImageUploader

  # Model Relationships
  belongs_to :project
  belongs_to :design
  belongs_to :user

  # Model Validation
  validates :project_id, :design_id, :user_id, presence: true

  # Model Methods

  def to_slug
    name.to_s.parameterize
  end

  def level_name
    LEVELS.find { |_name, value| value == level }.first
  rescue
    'Section'
  end
end
