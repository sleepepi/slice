# frozen_string_literal: true

class ProjectFavorite < ApplicationRecord
  # Model Relationships
  belongs_to :project
  belongs_to :user
end
