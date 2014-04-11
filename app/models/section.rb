class Section < ActiveRecord::Base

  mount_uploader :image, ImageUploader

  # Model Relationships
  belongs_to :project
  belongs_to :design
  belongs_to :user

  # Model Validation
  validates_presence_of :name, :project_id, :design_id, :user_id
  validates_uniqueness_of :name, scope: :design_id

end
