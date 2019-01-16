# frozen_string_literal: true

class AeTeam < ApplicationRecord
  # Constants
  ORDERS = {
    "abbr desc" => "ae_teams.short_name desc",
    "abbr" => "ae_teams.short_name",
    "name desc" => "ae_teams.name desc",
    "name" => "ae_teams.name",
    "pathways desc" => "ae_teams.pathways_count desc",
    "pathways" => "ae_teams.pathways_count"
  }
  DEFAULT_ORDER = "ae_teams.name"

  # Concerns
  include Deletable
  include Searchable
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

  has_many :ae_team_members
  has_many :managers, -> { current.where(ae_team_members: { manager: true }) }, through: :ae_team_members, source: :user
  has_many :principal_reviewers, -> { current.where(ae_team_members: { principal_reviewer: true }) }, through: :ae_team_members, source: :user
  has_many :reviewers, -> { current.where(ae_team_members: { reviewer: true }) }, through: :ae_team_members, source: :user
  has_many :viewers, -> { current.where(ae_team_members: { viewer: true }) }, through: :ae_team_members, source: :user

  has_many :no_role_users, -> { current.where(ae_team_members: { manager: false, principal_reviewer: false, reviewer: false, viewer: false }) }, through: :ae_team_members, source: :user

  has_many :ae_team_pathways, -> { current }
  has_many :ae_assignments, -> { current }

  def current_and_deleted_assignments
    ae_assignments.unscope(where: :deleted)
  end

  # Methods

  def self.searchable_attributes
    %w(name short_name)
  end
end
