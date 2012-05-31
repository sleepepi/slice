class Site < ActiveRecord::Base
  attr_accessible :description, :emails, :name, :project_id

    # Named Scopes
  scope :current, conditions: { deleted: false }

  # Model Validation
  validates_presence_of :name, :project_id, :user_id
  validates_uniqueness_of :name, scope: [:project_id, :deleted]

  # Model Relationships
  belongs_to :user
  belongs_to :project

  # Model Methods
  def destroy
    update_attribute :deleted, true
  end

end
