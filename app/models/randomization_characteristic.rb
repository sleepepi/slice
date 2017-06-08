# frozen_string_literal: true

# Tracks what criteria were selected for randomization.
class RandomizationCharacteristic < ApplicationRecord
  # Relationships
  belongs_to :project
  belongs_to :randomization_scheme
  belongs_to :list
  belongs_to :randomization
  belongs_to :stratification_factor
  belongs_to :stratification_factor_option, optional: true
  belongs_to :site, optional: true
end
