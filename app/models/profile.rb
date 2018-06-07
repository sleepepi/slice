# frozen_string_literal: true

# Creates a public profile for users and organizations.
class Profile < ApplicationRecord
  # Concerns
  include Strippable
  strip :username

  include Squishable
  squish :description

  # Validations
  validates :username, format: {
                         with: /\A[a-zA-Z0-9]+\Z/i,
                         message: "may only contain letters or digits"
                       },
                       exclusion: { in: %w(new edit show create update destroy library slice) },
                       uniqueness: { case_sensitive: false }
  validates :user_id, uniqueness: true, allow_nil: true
  validates :organization_id, uniqueness: true, allow_nil: true
  validate :presence_of_user_xor_organization

  # Relationships
  belongs_to :user, optional: true
  belongs_to :organization, optional: true

  has_many :trays

  def self.find_by_param(input)
    find_by(username: input.to_param)
  end

  def to_param
    username_was
  end

  def object
    user || organization
  end

  def editable_by?(current_user)
    return false unless current_user
    current_user.profiles.find_by(id: id).present?
  end

  private

  # User XOR organization needs to be present, one or the other, not both.
  def presence_of_user_xor_organization
    unless user_id.nil? ^ organization_id.nil?
      errors.add(:base, "User or organization needs to be associated to this profile.")
    end
  end
end
