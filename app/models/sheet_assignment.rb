# frozen_string_literal: true

# Represents a sheet completed by an AE reviewer for a particular review group.

# AeAdverseEvent
# `- AeReviewTeam
#    `- AeTeamPathway
#       `- AeReviewGroup
#          `- AeAdverseEventReviewerAssignment   <=>  SheetAssignment  <=>  Sheet
class SheetAssignment < ApplicationRecord
  # Relationships
  belongs_to :project
  belongs_to :sheet
  belongs_to :ae_adverse_event
  belongs_to :ae_review_team
  belongs_to :ae_team_pathway
  belongs_to :ae_adverse_event_reviewer_assignment
end
