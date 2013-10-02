class Schedule < ActiveRecord::Base

  serialize :items, Array

  # Concerns
  include Searchable, Deletable

  # Model Validation
  validates_presence_of :project_id, :user_id, :name
  validates_uniqueness_of :name, scope: [:deleted, :project_id]

  # Model Relationships
  belongs_to :user
  belongs_to :project

  # Model Methods

end
