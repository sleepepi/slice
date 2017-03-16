# frozen_string_literal: true

# Tracks a series of designs filled out on an event date for a subject
class SubjectEvent < ApplicationRecord
  # Validations
  validates :event_date, presence: true

  # Relationships
  belongs_to :subject
  belongs_to :event
  belongs_to :user
  has_many :sheets, -> { current }

  scope :with_current_subjects, -> { joins(:subject).merge(Subject.current) }

  # Methods

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

  def unblinded_required_sheets
    sheets.where(design_id: required_design_ids).where.not(total_response_count: nil)
  end

  def missing_unblinded_required_designs_question_count
    covered_design_ids = unblinded_required_sheets.pluck(:design_id)
    missing_design_ids = required_design_ids.reject { |id| covered_design_ids.include?(id) }
    subject.project.designs.where(id: missing_design_ids).sum(:variables_count)
  end

  def blinded_required_sheets
    if subject.project.blinding_enabled?
      sheets.where(design_id: required_design_ids)
            .joins(:design).where(designs: { only_unblinded: false })
            .where.not(total_response_count: nil)
    else
      unblinded_required_sheets
    end
  end

  def missing_blinded_required_designs_question_count
    missing_unblinded_required_designs_question_count unless subject.project.blinding_enabled?
    covered_design_ids = blinded_required_sheets.pluck(:design_id)
    missing_design_ids = required_design_ids.reject { |id| covered_design_ids.include?(id) }
    subject.project.designs.where(id: missing_design_ids, only_unblinded: false).sum(:variables_count)
  end

  def update_coverage!
    update_unblinded_coverage!
    update_blinded_coverage!
  end

  def update_unblinded_coverage!
    urcount = unblinded_required_sheets.sum(:response_count)
    uqcount = unblinded_required_sheets.sum(:total_response_count) + missing_unblinded_required_designs_question_count
    upercent = compute_percent(urcount, uqcount)
    update_columns(
      unblinded_responses_count: urcount,
      unblinded_questions_count: uqcount,
      unblinded_percent: upercent
    )
  end

  def update_blinded_coverage!
    brcount = blinded_required_sheets.sum(:response_count)
    bqcount = blinded_required_sheets.sum(:total_response_count) + missing_blinded_required_designs_question_count
    bpercent = compute_percent(brcount, bqcount)
    update_columns(
      blinded_responses_count: brcount,
      blinded_questions_count: bqcount,
      blinded_percent: bpercent
    )
  end

  # 0 out of 0 questions answered is 100% complete.
  def compute_percent(rcount, qcount)
    return 100 if qcount.zero?
    (rcount * 100.0 / qcount).to_i
  end
end
