# frozen_string_literal: true

# Allows main sections, subsections, and warnings to be added to designs.
class Section < ApplicationRecord
  # Constants
  LEVELS = [
    ["Section", 0],
    ["Subsection", 1],
    ["Informational", 2],
    ["Warning", 3],
    ["Alert", 4]
  ]

  # Concerns
  include Translatable
  translates :name, :description

  # Uploaders
  mount_uploader :image, ImageUploader

  # Relationships
  belongs_to :project
  belongs_to :design
  belongs_to :user

  # Methods

  def to_slug
    name.to_s.parameterize
  end

  def level_name
    LEVELS.find { |_name, value| value == level }&.first || "Section"
  end

  def display_on_report?
    level.in?(0..1)
  end
end
