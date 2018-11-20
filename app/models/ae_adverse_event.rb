# frozen_string_literal: true

class AeAdverseEvent < ApplicationRecord
  # Concerns
  include Deletable
  include Squishable

  squish :description

  # Validations
  validates :description, presence: true

  # Relationships
  belongs_to :project
  belongs_to :user
  belongs_to :subject
  belongs_to :closer, class_name: "User", foreign_key: "closer_id", optional: true
  has_many :ae_adverse_event_log_entries, -> { order(:id) }
  has_many :ae_adverse_event_info_requests
  has_many :ae_adverse_event_review_teams, -> { order(:ae_review_team_id) }
  has_many :ae_adverse_event_reviewer_assignments

  # Methods
  def name
    "AE##{number || "???"}"
  end

  def generate_number!
    update number: adverse_event_number
  end

  def adverse_event_number
    self.class.where(project: project).order(:created_at).pluck(:id).index(id)&.send(:+, 1)
  end

  def closed?
    !closed_at.nil?
  end

  def subject_code
    subject&.subject_code
  end

  def subject_code=(code)
    s = project.subjects.find_by "LOWER(subject_code) = ?", code.to_s.downcase
    self.subject_id = (s ? s.id : nil)
  end

  # Logs and notifications
  def opened!(current_user)
    # TODO: AE Notifications
    #   @adverse_event.create_notifications
    #   @adverse_event.send_email_in_background
    generate_number!
    ae_adverse_event_log_entries.create(project: project, user: current_user, entry_type: "ae_opened")
  end

  def assign_team!(current_user, team)
    ae_adverse_event_review_teams.where(project: project, ae_review_team: team).first_or_create
    ae_adverse_event_log_entries.create(project: project, user: current_user, entry_type: "ae_team_assigned", ae_review_team: team)
    # TODO: Generate in app notifications and LOG notifications for assignment to team (notify team managers, in this case team managers)
  end
end
