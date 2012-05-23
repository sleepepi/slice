class Design < ActiveRecord::Base
  attr_accessible :description, :name, :variable_ids

  # Named Scopes
  scope :current, conditions: { deleted: false }

  # Model Validation
  validates_presence_of :name, :user_id
  validates_uniqueness_of :name, scope: [:deleted, :project_id]

  # Model Relationships
  belongs_to :user
  belongs_to :project
  has_many :sheets, conditions: { deleted: false }
  has_and_belongs_to_many :variables, conditions: { deleted: false }

  # Model Methods
  def destroy
    update_attribute :deleted, true
  end
end
