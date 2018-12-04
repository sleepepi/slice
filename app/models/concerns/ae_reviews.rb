# frozen_string_literal: true

module AeReviews
  extend ActiveSupport::Concern

  included do
    # Relationships
    has_many :ae_review_admins
    has_many :ae_review_teams, -> { current }
    has_many :ae_adverse_event_review_teams
    has_many :ae_adverse_events, -> { current }
    has_many :ae_adverse_event_log_entries, -> { order(:id) }
    has_many :ae_team_pathways, -> { current }
    has_many :ae_adverse_event_reviewer_assignments
    has_many :ae_designments
  end

  def ae_teams_enabled?
    adverse_event_reviews_enabled?
  end

  def ae_open_requests
    []
  end

  def ae_notifications
    []
  end
end
