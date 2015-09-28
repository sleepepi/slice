class Contact < ActiveRecord::Base
  # Concerns
  include Deletable

  # Model Validation
  validates :title, :name, :project_id, :user_id, presence: true

  # Model Relationships
  belongs_to :user
  belongs_to :project

  # Model Methods

  # Search Scope
  def self.search(arg)
    term = arg.to_s.downcase.gsub(/^| |$/, '%')
    query = 'LOWER(contacts.name) LIKE ? or LOWER(contacts.title) LIKE ?'
    where query, term, term
  end
end
