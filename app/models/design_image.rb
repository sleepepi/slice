# frozen_string_literal: true

# Allows images to be attached to design sections and descriptions.
class DesignImage < ApplicationRecord
  # Uploaders
  mount_uploader :file, DesignImageUploader

  # Validations
  validates :filename, presence: true

  # Relationships
  belongs_to :project
  belongs_to :design
  belongs_to :user

  # Methods
  def self.content_type(filename)
    MIME::Types.type_for(filename).first.content_type
  end
end
