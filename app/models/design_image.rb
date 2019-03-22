# frozen_string_literal: true

# Allows images to be attached to design sections and descriptions.
class DesignImage < ApplicationRecord
  # Callbacks
  before_validation :set_number

  # Uploaders
  mount_uploader :file, DesignImageUploader

  # Validations
  validates :filename, presence: true
  validates :number, presence: true, uniqueness: { scope: :design_id }

  # Relationships
  belongs_to :project
  belongs_to :design
  belongs_to :user

  # Methods
  def self.content_type(filename)
    MIME::Types.type_for(filename).first.content_type
  end

  private

  def set_number
    self[:number] = calculate_next_number
  end

  def calculate_next_number
    ([0] + design.design_images.pluck(:number)).compact.max + 1
  end
end
