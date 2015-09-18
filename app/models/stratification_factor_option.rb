class StratificationFactorOption < ActiveRecord::Base
  # Concerns
  include Deletable

  # Named Scopes

  # Model Validation
  validates :label, :user_id, :project_id, :randomization_scheme_id, :stratification_factor_id, presence: true
  validates :label, :value, uniqueness: { case_sensitive: false, scope: [:deleted, :project_id, :randomization_scheme_id, :stratification_factor_id] }
  validates :value, numericality: { greater_than_or_equal_to: 1, only_integer: true }

  # Model Relationships
  belongs_to :project
  belongs_to :randomization_scheme
  belongs_to :stratification_factor
  belongs_to :user

  # Model Methods

  def name
    "#{value}: #{label}"
  end
end
