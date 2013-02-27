class Contact < ActiveRecord::Base
  # Concerns
  include Deletable

  # Named Scopes
  scope :search, lambda { |arg| where("LOWER(contacts.name) LIKE ? or LOWER(contacts.title) LIKE ?", arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%')) }

  # Model Validation
  validates_presence_of :title, :name, :project_id, :user_id

  # Model Relationships
  belongs_to :user
  belongs_to :project

  # Model Methods

end
