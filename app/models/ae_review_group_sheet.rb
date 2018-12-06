# frozen_string_literal: true

# Represents a AE review team final sheet for an assigned pathway and review
# group.

# AeAdverseEvent
# `- AeReviewTeam
#    `- AeTeamPathway
#       `- AeReviewGroup   <=>  AeReviewGroupSheet  <=>  Sheet
class AeReviewGroupSheet < ApplicationRecord
  # Validations
  validates :sheet_id, uniqueness: { scope: :ae_review_group_id }

  # Relationships
  belongs_to :project
  belongs_to :ae_review_group
  belongs_to :sheet
end
