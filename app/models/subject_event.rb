# frozen_string_literal: true

# Tracks a series of designs filled out on an event date for a subject
class SubjectEvent < ApplicationRecord
  # Model Validation
  validates :event_date, presence: true

  # Model Relationships
  belongs_to :subject
  belongs_to :event
  belongs_to :user
  has_many :sheets, -> { current }

  scope :with_current_subjects, -> { joins(:subject).merge(Subject.current) }

  # Model Methods

  def name
    event.name if event
  end

  def event_at
    created_at
  end

  def event_date_to_param
    event_date ? event_date.strftime('%Y%m%d') : 'no-date'
  end

  def event_date_to_s
    event_date ? event_date.strftime('%a, %b %-d, %Y') : 'No Date'
  end

  def event_date_to_s_xs
    event_date ? event_date.strftime('%b %-d, %Y') : 'No Date'
  end

  def event_name_and_date
    [name, event_date_to_s].compact.join(' - ')
  end

  def unlink_sheets!(current_user, remote_ip)
    sheets.find_each do |sheet|
      SheetTransaction.save_sheet!(
        sheet,
        {
          subject_event_id: nil,
          last_user_id: current_user.id,
          last_edited_at: Time.zone.now
        }, {}, current_user, remote_ip, 'sheet_update', skip_validation: true
      )
    end
  end

  def handoffs?
    event.event_designs.where(handoff_enabled: true).count > 0
  end
end
