class Document < ActiveRecord::Base
  mount_uploader :file, GenericUploader

  # Concerns
  include Deletable

  # Named Scopes
  scope :search, -> (arg) { where('LOWER(documents.name) LIKE ? or LOWER(documents.category) LIKE ?', arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%')) }

  # Model Validation
  validates :name, :category, :file, :project_id, :user_id, presence: true

  # Model Relationships
  belongs_to :user
  belongs_to :project

  # Model Methods
end
