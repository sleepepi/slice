# frozen_string_literal: true

# Generic invite class to allow users to be invited as project users, site
# users, AE review admins, and AE team members.
class Invite < ApplicationRecord
  # Constants
  PROJECT_ROLES = [
    { name: "Project Editor", role: "project_editor_unblinded", blinded: false, adverse_events: false },
    { name: "Project Viewer", role: "project_viewer_unblinded", blinded: false, adverse_events: false },
    { name: "Project Editor", role: "project_editor_blinded", blinded: true, adverse_events: false },
    { name: "Project Viewer", role: "project_viewer_blinded", blinded: true, adverse_events: false },
    { name: "AE Review Admin", role: "ae_admin", blinded: false, adverse_events: true }
  ]

  SITE_ROLES = [
    { name: "Site Editor", role: "site_editor_unblinded", blinded: false, adverse_events: false },
    { name: "Site Viewer", role: "site_viewer_unblinded", blinded: false, adverse_events: false },
    { name: "Site Editor", role: "site_editor_blinded", blinded: true, adverse_events: false },
    { name: "Site Viewer", role: "site_viewer_blinded", blinded: true, adverse_events: false }
  ]

  AE_TEAM_ROLES = [
    { name: "AE Team Manager", role: "ae_team_manager", blinded: false, adverse_events: true },
    { name: "AE Team Principal Reviewer", role: "ae_team_principal_reviewer", blinded: false, adverse_events: true },
    { name: "AE Team Reviewer", role: "ae_team_reviewer", blinded: false, adverse_events: true },
    { name: "AE Team Viewer", role: "ae_team_viewer", blinded: false, adverse_events: true }
  ]

  ROLES = PROJECT_ROLES + SITE_ROLES + AE_TEAM_ROLES

  ORDERS = {
    "subgroup desc" => "invites.subgroup_type desc, invites.subgroup_id desc",
    "subgroup" => "invites.subgroup_type, invites.subgroup_id",
    "email desc" => "invites.email desc",
    "email" => "invites.email",
    "role desc" => "invites.role desc",
    "role" => "invites.role",
    "status desc" => "invites.accepted_at desc nulls last, invites.declined_at desc nulls last",
    "status" => "invites.accepted_at nulls first, invites.declined_at nulls first"
  }
  DEFAULT_ORDER = "invites.role"

  # Concerns
  include Searchable

  attr_writer :role_level

  # Validations
  validates :email, :role, presence: true
  validates :role, inclusion: { in: ROLES.collect { |h| h[:role] } }
  validate :roles_with_subgroups

  # Relationships
  belongs_to :project
  belongs_to :inviter, class_name: "User", foreign_key: "inviter_id"
  belongs_to :subgroup, polymorphic: true, optional: true

  # Methods

  def self.searchable_attributes
    %w(email role)
  end

  def accepted?
    !accepted_at.nil?
  end

  def declined?
    !declined_at.nil?
  end

  def role_name
    hash = ROLES.find { |h| h[:role] == role }
    if hash && project.blinding_enabled? && hash[:adverse_events] == false
      "#{hash[:name]} #{hash[:blinded] ? " - Blinded" : " - Unblinded"}"
    elsif hash
      hash[:name]
    end
  end

  def role_level
    return @role_level if new_record?

    case subgroup.class.to_s
    when "Site"
      "site"
    when "AeTeam"
      "ae_team"
    else
      "project"
    end
  end

  def email=(email)
    super(email.try(:downcase).try(:squish))
  end

  private

  def roles_with_subgroups
    errors.add(:site, "must be selected") if requires_site?
    errors.add(:team, "must be selected") if requires_team?
  end

  def requires_site?
    (role.in?(SITE_ROLES.collect { |h| h[:role] }) || role_level == "site") && subgroup.class != Site
  end

  def requires_team?
    (role.in?(AE_TEAM_ROLES.collect { |h| h[:role] }) || role_level == "ae_team") && subgroup.class != AeTeam
  end
end
