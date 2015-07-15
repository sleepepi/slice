class TreatmentArm < ActiveRecord::Base

  # Concerns
  include Deletable

  # Named Scopes

  scope :positive_allocation, -> { where 'treatment_arms.allocation > 0' }

  # Model Validation
  validates_presence_of :name, :user_id, :project_id, :randomization_scheme_id
  validates_uniqueness_of :name, case_sensitive: false, scope: [:deleted, :project_id, :randomization_scheme_id]
  validates_numericality_of :allocation, greater_than_or_equal_to: 0, only_integer: true

  # Model Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :randomization_scheme

  # Model Methods

end
