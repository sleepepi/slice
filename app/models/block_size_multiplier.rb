# frozen_string_literal: true

# Specifies the value and allocation of blocks for randomization schemes using
# the permuted-block algorithm.
class BlockSizeMultiplier < ApplicationRecord
  # Concerns
  include Deletable

  # Scopes

  # Model Validation
  validates :user_id, :project_id, :randomization_scheme_id, presence: true
  validates :value, uniqueness: { scope: [:deleted, :project_id, :randomization_scheme_id] }
  validates :value, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :allocation, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  # Model Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :randomization_scheme

  # Model Methods

  def name
    "x#{value}"
  end

  def name_was
    "x#{value_was}"
  end
end
