# frozen_string_literal: true

# Provides methods to invite a new member to an existing project
class ProjectUser < ApplicationRecord
  # Concerns
  include Forkable

  # Relationships
  belongs_to :project
  belongs_to :user
end
