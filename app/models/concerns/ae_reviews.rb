# frozen_string_literal: true

module AeReviews
  extend ActiveSupport::Concern

  included do
    # Relationships
    has_many :ae_review_teams, -> { current }
    has_many :ae_adverse_events, -> { current }
    has_many :ae_adverse_event_log_entries, -> { order(:id) }
  end

  def ae_teams_enabled?
    adverse_event_reviews_enabled?
  end

  def ae_admins
    []
  end

  def ae_open_requests
    []
  end

  def ae_notifications
    []
  end
end
