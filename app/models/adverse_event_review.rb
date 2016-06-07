# frozen_string_literal: true

# - **Adverse Event Changes**
#   - Project and site editors can now generate links to send adverse event
#     summaries to medical monitors
#   - External adverse event reviewers can leave their name and comment on the
#     adverse event
class AdverseEventReview < ApplicationRecord
  # Model Validation
  validates :adverse_event_id, :name, :comment, presence: true

  # Model Relationships
  belongs_to :adverse_event
end
