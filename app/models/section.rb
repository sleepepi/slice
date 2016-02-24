# frozen_string_literal: true

# Allows main sections, subsections, and warnings to be added to designs
class Section < ActiveRecord::Base
  mount_uploader :image, ImageUploader

  # Model Relationships
  belongs_to :project
  belongs_to :design
  belongs_to :user

  # Model Validation
  validates :name, :project_id, :design_id, :user_id, presence: true

  # Model Methods

  def to_slug
    name.parameterize
  end

  def level_name
    case level
    when 0
      'section'
    when 1
      'subsection'
    when 2
      'warning'
    end
  end
end
