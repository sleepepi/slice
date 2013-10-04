class Event < ActiveRecord::Base

  # Concerns
  include Searchable, Deletable

  # Named Scopes

  # Model Validation
  validates_presence_of :name, :project_id, :user_id
  validates_uniqueness_of :name, scope: [ :project_id, :deleted ]

  # Model Relationships
  belongs_to :user
  belongs_to :project

  # Model Methods


end
