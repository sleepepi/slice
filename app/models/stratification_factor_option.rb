class StratificationFactorOption < ActiveRecord::Base

  # Concerns
  include Deletable

  # Named Scopes

  # Model Validation
  validates_presence_of :label, :user_id, :project_id, :randomization_scheme_id, :stratification_factor_id
  validates_uniqueness_of :label, case_sensitive: false, scope: [:deleted, :project_id, :randomization_scheme_id, :stratification_factor_id]
  validates_uniqueness_of :value, case_sensitive: false, scope: [:deleted, :project_id, :randomization_scheme_id, :stratification_factor_id]
  validates_numericality_of :value, greater_than_or_equal_to: 1, only_integer: true

  # Model Relationships
  belongs_to :project
  belongs_to :randomization_scheme
  belongs_to :stratification_factor
  belongs_to :user

  # Model Methods

  def name
    "#{self.value}: #{self.label}"
  end

end
