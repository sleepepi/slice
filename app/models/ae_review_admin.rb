# frozen_string_literal: true

class AeReviewAdmin < ApplicationRecord
  # Concerns

  # Validations
  validates :user_id, uniqueness: { scope: [:project_id] }

  # Relationships
  belongs_to :project
  belongs_to :user
end
