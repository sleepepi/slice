class Sheet < ActiveRecord::Base
  attr_accessible :description, :design_id, :name, :project_id, :study_date, :subject_id, :variable_ids

  # Named Scopes
  scope :current, conditions: { deleted: false }

  # Model Validation
  validates_presence_of :design_id, :name, :project_id, :study_date, :subject_id, :user_id
  validates_uniqueness_of :study_date, scope: [:project_id, :subject_id, :design_id, :deleted]

  # Model Relationships
  belongs_to :user
  belongs_to :design
  belongs_to :project
  belongs_to :subject
  has_many :variables, conditions: { deleted: false }

  # Model Methods
  def destroy
    update_attribute :deleted, true
  end
end
