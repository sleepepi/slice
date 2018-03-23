# frozen_string_literal: true

# Stores a single translation for an object attribute.
class Translation < ApplicationRecord
  # Validations
  validates :translatable_attribute, :locale, :translation, presence: true

  # Relationships
  belongs_to :translatable, polymorphic: true
end
