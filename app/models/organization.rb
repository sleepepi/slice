# frozen_string_literal: true

# Allows forms to be grouped under one organization
class Organization < ApplicationRecord
  # Concerns
  include Searchable

  # Validations
  validates :name, presence: true

  # Relationships
  has_one :profile

  # Methods
  def self.searchable_attributes
    %w(name)
  end
end
