class Post < ActiveRecord::Base
  # attr_accessible :archived, :description, :name, :project_id, :user_id

  # Concerns
  include Searchable, Deletable

  # Named Scopes

  # Model Validation
  validates_presence_of :name, :description, :project_id, :user_id

  # Model Relationships
  belongs_to :user
  belongs_to :project

  # Model Methods

end
