class AdverseEvent < ActiveRecord::Base
  # Concerns
  include DateAndTimeParser, Deletable, Searchable, Siteable

  # Model Validation
  validates :adverse_event_date, :description, presence: true
  validates :project_id, :subject_id, :user_id, presence: true

  # Model Relationships
  belongs_to :project
  belongs_to :subject
  belongs_to :user

  # Model Methods

  def name
    "AE##{id}"
  end

  def editable_by?(current_user)
    current_user.all_adverse_events.where(id: id).count == 1
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
end
