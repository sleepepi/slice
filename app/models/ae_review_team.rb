# frozen_string_literal: true

class AeReviewTeam < ApplicationRecord
  # Concerns
  include Deletable
  include Sluggable
  include Squishable

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

  has_many :ae_team_pathways, -> { current }
end
