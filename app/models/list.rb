class List < ActiveRecord::Base

  # Concerns
  include Deletable

  # Named Scopes

  # Model Validation
  validates_presence_of :project_id, :randomization_scheme_id, :user_id, :name

  # Model Relationships
  belongs_to :project
  belongs_to :randomization_scheme
  belongs_to :user
  has_many :list_options
  has_many :options, through: :list_options
  has_many :randomizations, -> { where deleted: false }

  # Model Methods

end
