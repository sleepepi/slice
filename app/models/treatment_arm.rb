# frozen_string_literal: true

# Defines a treatment arm assignment for randomized subjects.
class TreatmentArm < ApplicationRecord
  # Concerns
  include Deletable, ShortNameable, Squishable

  squish :name

  # Scopes
  scope :positive_allocation, -> { where 'treatment_arms.allocation > 0' }

  # Model Validation
  validates :name, :user_id, :project_id, :randomization_scheme_id, presence: true
  validates :name, uniqueness: { case_sensitive: false, scope: [:deleted, :project_id, :randomization_scheme_id] }
  validates :allocation, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  # Model Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :randomization_scheme

  # Model Methods
end
