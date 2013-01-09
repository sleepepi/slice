class Document < ActiveRecord::Base
  attr_accessible :archived, :category, :file, :file_cache, :name, :project_id, :user_id

  mount_uploader :file, GenericUploader

  # Concerns
  include Deletable

  # Named Scopes

  # Model Validation
  validates_presence_of :name, :category, :file, :project_id, :user_id

  # Model Relationships
  belongs_to :user
  belongs_to :project

  # Model Methods

end
