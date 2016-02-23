# frozen_string_literal: true

# Allows specification of monthly recruitment goals by site for a randomization
# scheme
class ExpectedRandomization < ActiveRecord::Base
  # Model Validation
  validates :randomization_scheme_id, :site_id, presence: true

  # Model Relationships
  belongs_to :randomization_scheme
  belongs_to :site
end
