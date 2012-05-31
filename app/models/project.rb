class Project < ActiveRecord::Base
  attr_accessible :description, :name

  # Named Scopes
  scope :current, conditions: { deleted: false }

  # Model Validation
  validates_presence_of :name, :user_id
  validates_uniqueness_of :name, scope: :deleted

  # Model Relationships
  belongs_to :user
  has_many :sheets, conditions: { deleted: false }
  has_many :sites, conditions: { deleted: false }
  has_many :subjects, conditions: { deleted: false }

  # Model Methods
  def destroy
    update_attribute :deleted, true
  end
end
