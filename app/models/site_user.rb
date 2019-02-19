# frozen_string_literal: true

# Provides methods to invite a user by email as a site member.
class SiteUser < ApplicationRecord
  # Concerns
  include Forkable

  # Relationships
  belongs_to :project
  belongs_to :site
  belongs_to :user
end
