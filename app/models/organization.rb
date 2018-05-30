# frozen_string_literal: true

# Allows forms to be grouped under one organization
class Organization < ApplicationRecord
  # Concerns
  include Searchable

  # Uploaders
  mount_uploader :profile_picture, ResizableImageUploader

  # Validations
  validates :name, presence: true

  # Relationships
  has_one :profile
  has_many :organization_users
  has_many :members, -> { current.joins(:profile).order(:full_name) }, through: :organization_users, source: :user

  # Methods
  def self.searchable_attributes
    %w(name)
  end
end
