# frozen_string_literal: true

class AeReviewTeam < ApplicationRecord
  # Concerns
  include Deletable
  include Sluggable
  include Squishable
  include ShortNameable

  squish :name

  # Validations
  validates :name, presence: true
  validates :slug, format: { with: /\A[a-z][a-z0-9\-]*\Z/ },
                   exclusion: { in: %w(new edit create update destroy) },
                   uniqueness: :project_id,
                   allow_nil: true

  # Relationships
  belongs_to :project

  has_many :ae_review_team_members
  has_many :managers, -> { current.where(ae_review_team_members: { manager: true }) }, through: :ae_review_team_members, source: :user
  has_many :reviewers, -> { current.where(ae_review_team_members: { reviewer: true }) }, through: :ae_review_team_members, source: :user
  has_many :viewers, -> { current.where(ae_review_team_members: { viewer: true }) }, through: :ae_review_team_members, source: :user

  has_many :no_role_users, -> { current.where(ae_review_team_members: { manager: false, reviewer: false, viewer: false }) }, through: :ae_review_team_members, source: :user

  has_many :ae_review_groups
  has_many :ae_team_pathways, -> { current }
  has_many :ae_adverse_event_reviewer_assignments

  # Methods

  def assign_pathway!(current_user, adverse_event, pathway)
    review_group = ae_review_groups.where(ae_team_pathway: pathway).first_or_create(
      project: project,
      ae_adverse_event: adverse_event,
      ae_team_pathway: pathway
    )

    reviewers = random_reviewers(pathway)
    assignments = []
    reviewers.each do |reviewer|
      assignments << ae_adverse_event_reviewer_assignments.create(
        project: project,
        ae_adverse_event: adverse_event,
        ae_review_group: review_group,
        manager: current_user,
        reviewer: reviewer,
        ae_team_pathway: pathway
      )
      # TODO: Generate in app notifications, email, and LOG notificiations to AENotificationsLog for Info Request (to "reviewer")
    end
    adverse_event.ae_adverse_event_log_entries.create(
      project: project,
      user: current_user,
      entry_type: "ae_reviewers_assigned",
      ae_review_team: self,
      reviewer_assignments: assignments
    )
    review_group
  end

  private

  def random_reviewers(pathway)
    if pathway.number_of_reviewers.zero?
      reviewers
    else
      reviewers.sample(pathway.number_of_reviewers)
    end
  end
end
