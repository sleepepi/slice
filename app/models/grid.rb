# frozen_string_literal: true

class Grid < ApplicationRecord
  # Concerns
  include Formattable, Valuable

  # Scopes
  scope :with_files, -> { joins(:variable).where(variables: { variable_type: 'file' }).where.not(response_file: [nil, '']) }

  # Model Validation
  validates :sheet_variable_id, :position, presence: true

  # Model Relationships
  belongs_to :sheet_variable, touch: true
  belongs_to :user

  delegate :sheet_id, to: :sheet_variable
end
