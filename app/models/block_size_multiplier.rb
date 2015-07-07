class BlockSizeMultiplier < ActiveRecord::Base

  # Concerns
  include Deletable

  # Named Scopes

  # Model Validation
  validates_presence_of :user_id, :project_id, :randomization_scheme_id
  validates_uniqueness_of :value, scope: [:deleted, :project_id, :randomization_scheme_id]
  validates_numericality_of :value, greater_than_or_equal_to: 1, only_integer: true
  validates_numericality_of :allocation, greater_than_or_equal_to: 0, only_integer: true

  # Model Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :randomization_scheme

  # Model Methods

  def name
    "x#{self.value}"
  end

end
