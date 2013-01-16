class Link < ActiveRecord::Base
  attr_accessible :archived, :category, :deleted, :name, :project_id, :url, :user_id

  # Concerns
  include Deletable

  # Named Scopes

  # Model Validation
  validates_presence_of :name, :category, :url, :project_id, :user_id

  # Model Relationships
  belongs_to :user
  belongs_to :project

  # Model Methods

end
