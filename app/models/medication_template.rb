# frozen_string_literal: true

# Stores medication names
class MedicationTemplate < ApplicationRecord
  # Concerns
  include Searchable

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :project_id }

  # Relationships
  belongs_to :project

  # Methods
  def self.searchable_attributes
    %w(name)
  end
end
