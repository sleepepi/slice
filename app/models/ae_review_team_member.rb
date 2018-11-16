class AeReviewTeamMember < ApplicationRecord
  # Concerns

  # Validations

  # Relationships
  belongs_to :project
  belongs_to :ae_review_team
  belongs_to :user
end
