class Section < ActiveRecord::Base
  mount_uploader :image, ImageUploader

  # Model Relationships
  belongs_to :project
  belongs_to :design
  belongs_to :user

  # Model Validation
  validates :name, :project_id, :design_id, :user_id, presence: true
  validates :name, uniqueness: { scope: :design_id }

  # Model Methods

  def to_slug
    name.parameterize
  end
end
