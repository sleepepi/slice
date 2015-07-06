class RandomizationScheme < ActiveRecord::Base

  # Concerns
  include Searchable, Deletable

  # Named Scopes

  # Model Validation
  validates_presence_of :name, :user_id, :project_id
  validates_uniqueness_of :name, scope: [:deleted, :project_id]
  validates_numericality_of :randomization_goal, greater_than_or_equal_to: 0, only_integer: true

  # Model Relationships
  belongs_to :user
  belongs_to :project
  has_many :treatment_arms, -> { where deleted: false }

  # Model Methods

end
