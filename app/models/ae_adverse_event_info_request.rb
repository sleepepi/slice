# frozen_string_literal: true

# Represents a request for more information made by an Adverse Event Admin to
# the Adverse Event Reporter(s).
class AeAdverseEventInfoRequest < ApplicationRecord
  # Validations
  validates :comment, presence: true

  # Relationships
  belongs_to :project
  belongs_to :ae_adverse_event
  belongs_to :user
  belongs_to :resolver, class_name: "User", foreign_key: "resolver_id", optional: true
  belongs_to :ae_review_team, optional: true
end
