# Adverse events track the initial report and discussion of an adverse event,
# along with associated designs and files uploaded to the adverse event report.
class AdverseEvent < ActiveRecord::Base
  # Concerns
  include DateAndTimeParser, Deletable, Searchable, Siteable, Forkable

  # Model Alerts
  after_create :send_email_in_background

  # Model Validation
  validates :adverse_event_date, :description, presence: true
  validates :project_id, :subject_id, :user_id, presence: true

  # Model Relationships
  belongs_to :project
  belongs_to :subject
  belongs_to :user
  has_many :adverse_event_comments, -> { order :created_at }
  has_many :adverse_event_files
  has_many :adverse_event_users
  has_many :sheets, -> { where deleted: false }

  # Model Methods

  def name
    "AE##{id}"
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
    subjects = project.subjects.where 'LOWER(subject_code) = ?', code.to_s.downcase
    s = subjects.first
    self.subject_id = (s ? s.id : nil)
  end

  def event_date
    adverse_event_date ? adverse_event_date.strftime('%-m/%-d/%Y') : nil
  end

  def event_date=(date)
    self.adverse_event_date = parse_date(date)
  end

  def self.searchable_attributes
    %w(description)
  end

  # This function takes a series of sorted events and groups together adverse
  # event users to group users together who have seen the recent updates
  def compress_events(events)
    b = []
    events.each do |e|
      if e.is_a? AdverseEventUser
        if b.last.is_a? Array
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

  def self.blinding_scope(user)
    joins(:project)
      .joins("LEFT OUTER JOIN project_users ON project_users.project_id = projects.id and project_users.user_id = #{user.id}")
      .joins("LEFT OUTER JOIN site_users ON site_users.project_id = projects.id and site_users.user_id = #{user.id}")
      .where('projects.blinding_enabled = ? or projects.user_id = ? or project_users.unblinded = ? or site_users.unblinded = ?', false, user.id, true, true)
      .distinct
  end

  def self.generate_csv(project)
    CSV.generate do |csv|
      csv << csv_attributes
      project.adverse_events.find_each { |ae| csv << ae.to_csv_array }
    end
  end

  def to_csv_array
    AdverseEvent.csv_attributes.collect { |csv_attr| send(csv_attr) }
  end

  private

  # Adverse Events reports are sent to unblinded project editors
  def users_to_email
    project.unblinded_project_editors
  end

  def send_email_in_background
    fork_process(:send_email)
  end

  def send_email
    return if project.disable_all_emails? || ENV['emails_enabled'] != 'true'
    users_to_email.each do |user_to_email|
      UserMailer.adverse_event_reported(self, user_to_email).deliver_later
    end
  end

  def self.csv_attributes
    [:name, :reported_by, :subject_code, :reported_on, :description,
     :serious, :closed]
  end

  def reported_by
    user.name
  end

  def reported_on
    adverse_event_date
  end
end
