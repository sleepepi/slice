# frozen_string_literal: true

# Defines a specific value for a stratification factor.
class StratificationFactorOption < ApplicationRecord
  # Concerns
  include Deletable

  # Scopes

  # Validations
  validates :label, :user_id, :project_id, :randomization_scheme_id, :stratification_factor_id, presence: true
  validates :label, :value, uniqueness: {
    case_sensitive: false, scope: [:deleted, :project_id, :randomization_scheme_id, :stratification_factor_id]
  }
  validates :value, numericality: { greater_than_or_equal_to: 1, only_integer: true }

  # Relationships
  belongs_to :project
  belongs_to :randomization_scheme
  belongs_to :stratification_factor
  belongs_to :user

  # Methods

  def name
    "#{value}: #{label}"
  end

  def name_was
    "#{value_was}: #{label_was}"
  end
end
