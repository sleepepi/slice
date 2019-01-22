# frozen_string_literal: true

# Provides methods to invite a new member to an existing project
class ProjectUser < ApplicationRecord
  # Concerns
  include Forkable

  # Relationships
  belongs_to :creator, class_name: "User", foreign_key: "creator_id", optional: true # TODO: Remove this line in v70+.
  belongs_to :project
  belongs_to :user, optional: true # TODO: In v70+ should no longer be optional.
end
