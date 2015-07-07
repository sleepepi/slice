class StratificationFactor < ActiveRecord::Base

  # Concerns
  include Deletable

  # Named Scopes

  # Model Validation
  validates_presence_of :name, :user_id, :project_id, :randomization_scheme_id
  validates_uniqueness_of :name, case_sensitive: false, scope: [:deleted, :project_id, :randomization_scheme_id]

  # Model Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :randomization_scheme

  # Model Methods

  def options
    [["One", 1], ["Two", 2]]
  end

end
