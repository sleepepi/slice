# frozen_string_literal: true

# Describes a variable being collected along with the auto-complete values
class MedicationVariable < ApplicationRecord
  # Concerns
  include Deletable
  include Searchable

  # Validations
  validates :name, presence: true,
                   uniqueness: { case_sensitive: false, scope: :project_id }

  # Relationships
  belongs_to :project
  has_many :medication_values

  # Methods
  def autocomplete_values_array
    autocomplete_values&.split("\n")&.collect(&:strip)&.select(&:present?)
  end
end
