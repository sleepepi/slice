# frozen_string_literal: true

# Adverse events track the initial report and discussion of an adverse event,
# along with associated designs and files uploaded to the adverse event report.
class AdverseEvent < ApplicationRecord
  # Constants
  ORDERS = {
    'site' => 'sites.name',
    'site desc' => 'sites.name desc',
    'reported_by' => 'users.last_name, users.first_name',
    'reported_by desc' => 'users.last_name desc, users.first_name desc',
    'subject' => 'subjects.subject_code',
    'subject desc' => 'subjects.subject_code desc',
    'ae_date' => 'adverse_events.adverse_event_date',
    'ae_date desc' => 'adverse_events.adverse_event_date desc',
    'created' => 'adverse_events.created_at',
    'created desc' => 'adverse_events.created_at desc'
  }
  DEFAULT_ORDER = 'adverse_events.created_at desc'
  SHAREABLE_LINKS_ENABLED = false

  # Concerns
  include DateAndTimeParser, Deletable, Searchable, Siteable, Forkable, Blindable

  # Callbacks
  after_touch :create_notifications

  # Validations
  validates :adverse_event_date, presence: true
  validate :ae_date_cannot_be_in_future
  validates :description, presence: true
  validates :project_id, :subject_id, :user_id, presence: true
  validates :authentication_token, uniqueness: true, allow_nil: true

  # Relationships
  belongs_to :project
  belongs_to :subject
  belongs_to :user
  has_many :adverse_event_comments, -> { order :created_at }
  has_many :adverse_event_reviews, -> { order :created_at }
  has_many :adverse_event_files
  has_many :adverse_event_users
  has_many :sheets, -> { current }
  has_many :notifications

  delegate :site, to: :subject

  # Methods

  def event_at
    created_at
  end

  def name
    "AE##{number}"
  end

  def generate_number!
    update number: adverse_event_number
  end

  def adverse_event_number
    AdverseEvent.where(project: project).order(:created_at).pluck(:id).index(id) + 1
  rescue
    nil
  end

  def editable_by?(current_user)
    current_user.all_adverse_events.where(id: id).count == 1
  end

  def mark_as_viewed_by_user(current_user)
    adverse_event_user = adverse_event_users.find_or_create_by user_id: current_user.id
    adverse_event_user.update last_viewed_at: Time.zone.now
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    retry
  end

  def last_seen_at(current_user)
    adverse_event_user = adverse_event_users.find_by user_id: current_user.id
    adverse_event_user.last_viewed_at if adverse_event_user
  end

  def subject_code
    subject ? subject.subject_code : nil
  end

  def subject_code=(code)
    s = project.subjects.find_by 'LOWER(subject_code) = ?', code.to_s.downcase
    self.subject_id = (s ? s.id : nil)
  end

  def event_date
    adverse_event_date ? adverse_event_date.strftime('%-m/%-d/%Y') : nil
  end

  def event_date=(date)
    self.adverse_event_date = parse_date(date)
  end

  def ae_date_cannot_be_in_future
    return unless adverse_event_date && adverse_event_date > Time.zone.today
    errors.add(:adverse_event_date, "can't be in the future")
  end

  def self.searchable_attributes
    %w(description)
  end

  # This function takes a series of sorted events and groups together adverse
  # event users to group users together who have seen the recent updates
  def compress_events(events)
    b = []
    events.each do |e|
      if e.is_a?(AdverseEventUser)
        if b.last.is_a?(Array)
          b.last << e
        else
          b << [e]
        end
      else
        b << e
      end
    end
    b
  end

  def reported_by
    user.name
  end

  def reported_on
    adverse_event_date
  end

  def sort_event_date
    adverse_event_date
  end

  def event_date_to_s
    adverse_event_date ? adverse_event_date.strftime('%a, %b %-d, %Y') : 'No Date'
  end

  def event_date_to_s_xs
    adverse_event_date ? adverse_event_date.strftime('%b %-d, %Y') : 'No Date'
  end

  # Adverse Events reports are sent to unblinded project editors
  def users_to_email
    project.unblinded_members_for_site(site)
           .where.not(id: user_id)
           .where(emails_enabled: true)
           .select { |u| project.emails_enabled?(u) }
  end

  def send_email_in_background
    fork_process(:send_email)
  end

  def send_email
    return if !EMAILS_ENABLED || project.disable_all_emails?
    users_to_email.each do |user_to_email|
      UserMailer.adverse_event_reported(self, user_to_email).deliver_now
    end
  end

  def create_notifications
    project.unblinded_members_for_site(site).each do |u|
      notification = u.notifications.where(project_id: project_id, adverse_event_id: id).first_or_create
      notification.mark_as_unread!
    end
  end

  def destroy
    super
    notifications.destroy_all
    project.reset_adverse_event_numbers!
  end

  def id_and_token
    "#{id}-#{authentication_token}"
  end

  def set_token
    return unless authentication_token.blank?
    update authentication_token: SecureRandom.hex(12)
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    retry
  end
end
