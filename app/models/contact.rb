class Contact < ActiveRecord::Base
  attr_accessible :email, :fax, :name, :phone, :position, :user_id, :title, :project_id, :archived

  # Concerns
  include Deletable

  # Named Scopes

  # Model Validation
  validates_presence_of :title, :name, :project_id, :user_id

  # Model Relationships
  belongs_to :user
  belongs_to :project

  # Model Methods

end
