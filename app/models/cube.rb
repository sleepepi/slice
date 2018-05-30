# frozen_string_literal: true

class Cube < ApplicationRecord
  # Constants
  CUBE_TYPES = [
    "section", "string", "choice", "number"
  ]

  # Concerns
  include Strippable
  strip :text, :description

  # Relationships
  belongs_to :tray
  # has_many :faces, -> { order(:position) }, dependent: :destroy

  # Methods
  def name
    "Cube ##{id}"
  end
end
