class Subject < ActiveRecord::Base
  attr_accessible :project_id, :subject_code

  # Named Scopes
  scope :current, conditions: { deleted: false }

  # Model Validation
  validates_presence_of :project_id, :subject_code, :user_id
  validates_uniqueness_of :subject_code, scope: [:deleted, :project_id]

  def name
    self.subject_code
  end

  # Model Relationships
  belongs_to :user
  belongs_to :project
  has_many :sheets, conditions: { deleted: false }

  # Model Methods
  def destroy
    update_attribute :deleted, true
  end
end
