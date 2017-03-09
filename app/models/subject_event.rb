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

  # Filters designs on a subject event by the user's blinded status
  def designs_on_subject_event(current_user)
    current_user.all_viewable_designs.where(id: required_design_ids)
  end

  # Filters sheets on a subject event by the user's blinded status
  def sheets_on_subject_event(current_user)
    current_user.all_viewable_sheets
                .where(subject_event_id: id)
                .where(design_id: required_design_ids)
  end

  def extra_sheets_on_subject_event(current_user)
    current_user.all_viewable_sheets
                .where(subject_event_id: id)
                .where.not(design_id: required_design_ids)
  end

  def required_design_ids
    design_ids = []
    event.event_designs.each do |event_design|
      design_ids << event_design.design_id if event_design.required?(subject)
    end
    design_ids.uniq
  end

  def percent(current_user)
    sheets_started = sheets_on_subject_event(current_user).pluck(:design_id).uniq.count
    designs_count = designs_on_subject_event(current_user).count
    if designs_count.positive?
      sheets_started * 100 / designs_count
    else
      100
    end
  end
end
