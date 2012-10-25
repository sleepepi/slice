class Post < ActiveRecord::Base
  attr_accessible :archived, :description, :name, :project_id, :user_id

  # Named Scopes
  scope :current, conditions: { deleted: false }

  # Model Validation
  validates_presence_of :name, :description, :project_id, :user_id

  # Model Relationships
  belongs_to :user
  belongs_to :project

  # Model Methods
  def destroy
    update_column :deleted, true
  end

end
