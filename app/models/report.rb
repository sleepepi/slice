class Report < ActiveRecord::Base
  attr_accessible :name, :options

  serialize :options, Hash

  # Named Scopes
  scope :current, conditions: { deleted: false }

  # Model Validation
  validates_presence_of :user_id, :name

  # Model Relationships
  belongs_to :user

  # Model Methods
  def destroy
    update_column :deleted, true
  end

end
