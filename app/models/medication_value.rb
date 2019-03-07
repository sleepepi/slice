# frozen_string_literal: true

# Tracks a subject's medication value provided for a project medication
# variable.
class MedicationValue < ApplicationRecord
  # Validations
  validates :medication_variable_id, uniqueness: { scope: :medication_id }

  # Relationships
  belongs_to :project
  belongs_to :medication_variable
  belongs_to :subject
  belongs_to :medication
end
