# frozen_string_literal: true

class AeAdverseEventReviewerAssignment < ApplicationRecord
  # Validations

  validates :reviewer_id, uniqueness: { scope: [:ae_adverse_event_id, :ae_review_team_id, :ae_team_pathway_id] }

  # Relationships
  belongs_to :project
  belongs_to :ae_adverse_event
  belongs_to :ae_review_team
  belongs_to :ae_team_pathway
  belongs_to :manager, class_name: "User", foreign_key: "manager_id"
  belongs_to :reviewer, class_name: "User", foreign_key: "reviewer_id"
end
