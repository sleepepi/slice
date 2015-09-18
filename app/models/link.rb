class Link < ActiveRecord::Base
  # Concerns
  include Deletable

  # Named Scopes
  scope :search, -> (arg) { where('LOWER(links.name) LIKE ? or LOWER(links.category) LIKE ?', arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%')) }

  # Model Validation
  validates :name, :category, :url, :project_id, :user_id, presence: true

  # Model Relationships
  belongs_to :user
  belongs_to :project

  # Model Methods
end
