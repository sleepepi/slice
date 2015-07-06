class RandomizationScheme < ActiveRecord::Base

  # Concerns
  include Searchable, Deletable

  # Named Scopes

  # Model Validation
  validates_presence_of :name, :user_id, :project_id
  validates_uniqueness_of :name, scope: [:deleted, :project_id]

  # Model Relationships
  belongs_to :user
  belongs_to :project

  # Model Methods

end
