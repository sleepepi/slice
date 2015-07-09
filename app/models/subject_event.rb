class SubjectEvent < ActiveRecord::Base

  # Model Validation

  # Model Relationships
  belongs_to :subject
  belongs_to :event
  belongs_to :user
  has_many :sheets

  scope :with_valid_subjects, -> { joins(:subject).where(subjects: { status: 'valid', deleted: false }) }

  # Model Methods

  def event_at
    self.created_at
  end

  def event_date_to_param
    self.event_date ? self.event_date.strftime("%Y%m%d") : 'no-date'
  end

  def event_date_to_s
    self.event_date ? self.event_date.strftime("%a, %B %-d, %Y") : 'No Date'
  end

  def unlink_sheets!(current_user, remote_ip)
    self.sheets.each do |sheet|
      SheetTransaction.save_sheet!(sheet, { subject_event_id: nil, last_user_id: current_user.id, last_edited_at: Time.now }, { }, current_user, remote_ip, 'sheet_update')
    end
  end

end
