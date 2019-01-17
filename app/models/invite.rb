# frozen_string_literal: true

# Generic invite class to allow users to be invited as project users, site
# users, AE review admins, and AE team members.
class Invite < ApplicationRecord
  # Constants
  PROJECT_ROLES = [
    ["Project Editor - Unblinded", "project_editor_unblinded"],
    ["Project Viewer - Unblinded", "project_viewer_unblinded"],
    ["Project Editor - Blinded", "project_editor_blinded"],
    ["Project Viewer - Blinded", "project_viewer_blinded"],
    ["AE Review Admin", "ae_admin"]
  ]

  SITE_ROLES = [
    ["Site Editor - Unblinded", "site_editor_unblinded"],
    ["Site Viewer - Unblinded", "site_viewer_unblinded"],
    ["Site Editor - Blinded", "site_editor_blinded"],
    ["Site Viewer - Blinded", "site_viewer_blinded"]
  ]

  AE_TEAM_ROLES = [
    ["AE Team Manager", "ae_team_manager"],
    ["AE Team Principal Reviewer", "ae_team_principal_reviewer"],
    ["AE Team Reviewer", "ae_team_reviewer"],
    ["AE Team Viewer", "ae_team_viewer"]
  ]

  ROLES = PROJECT_ROLES + SITE_ROLES + AE_TEAM_ROLES

  attr_accessor :role_level

  # Callbacks
  after_create_commit :set_invite_token

  # Validations
  validates :email, :role, presence: true
  validates :invite_token, uniqueness: true, allow_nil: true
  validates :role, inclusion: { in: ROLES.collect(&:second) }

  # Relationships
  belongs_to :project
  belongs_to :inviter, class_name: "User", foreign_key: "inviter_id"
  belongs_to :subgroup, polymorphic: true, optional: true

  # Methods

  def claimed?
    !claimed_at.nil?
  end

  def role_name
    ROLES.find { |_name, value| value == role }&.first
  end

  private

  def set_invite_token
    return if invite_token.present?

    update invite_token: SecureRandom.hex(12)
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    retry
  end
end
