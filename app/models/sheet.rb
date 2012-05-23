class Sheet < ActiveRecord::Base
  attr_accessible :description, :design_id, :name, :project_id, :study_date, :subject_id, :variable_ids

  # Named Scopes
  scope :current, conditions: { deleted: false }

  # Model Validation
  validates_presence_of :design_id, :name, :project_id, :study_date, :subject_id, :user_id

  # Model Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :subject
  belongs_to :design
  has_and_belongs_to_many :variables, conditions: { deleted: false }

  # Model Methods
  def destroy
    update_attribute :deleted, true
  end
end
