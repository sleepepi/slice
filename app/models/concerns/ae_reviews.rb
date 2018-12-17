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
    has_many :ae_designments, -> { order(Arel.sql("position nulls last")) }
    has_many :ae_sheets
  end

  def ae_teams_enabled?
    adverse_event_reviews_enabled?
  end

  def ae_notifications
    []
  end

  def ae_designs(role)
    designs.joins(:ae_designments).merge(AeDesignment.where(role: role))
  end

  def first_design(role)
    ae_designs(role).first
  end

  def next_design(role, design)
    design_array = ae_designs(role).to_a
    number = design_array.collect(&:id).index(design.id)
    design_array[number + 1] if number
  end

  def ae_admin?(current_user)
    ae_review_admins.where(user: current_user).count == 1
  end

  def ae_reporter?(current_user)
    site_or_project_editor?(current_user)
  end
end
