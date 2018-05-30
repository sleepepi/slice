# frozen_string_literal: true

# Handles organization membership.
class OrganizationUser < ApplicationRecord
  # Relationships
  belongs_to :organization
  belongs_to :user
end
