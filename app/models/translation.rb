# frozen_string_literal: true

# Stores a single translation for an object attribute.
class Translation < ApplicationRecord
  # Concerns
  include Strippable

  strip :translation

  # Validations
  validates :translatable_attribute, :language_code, presence: true

  # Relationships
  belongs_to :translatable, polymorphic: true
end
