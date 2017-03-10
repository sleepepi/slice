# frozen_string_literal: true

# Allows specification of monthly recruitment goals by site for a randomization
# scheme
class ExpectedRandomization < ApplicationRecord
  # Validations
  validates :randomization_scheme_id, :site_id, presence: true

  # Relationships
  belongs_to :randomization_scheme
  belongs_to :site
end
