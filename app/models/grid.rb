# frozen_string_literal: true

# Represents a single cell response for a grid variable. Defines the position
# (row), parent grid variable, and child variable.
class Grid < ApplicationRecord
  # Concerns
  include Formattable, Valuable

  # Scopes
  scope :with_files, -> { file_variables.where.not(response_file: [nil, '']) }

  # Model Validation
  validates :sheet_variable_id, :position, presence: true

  # Model Relationships
  belongs_to :sheet_variable, touch: true
  belongs_to :user
  belongs_to :domain_option

  delegate :sheet_id, to: :sheet_variable

  # Methods
  def self.file_variables
    joins(:variable).where(variables: { variable_type: 'file' })
  end
end
