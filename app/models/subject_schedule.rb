class SubjectSchedule < ActiveRecord::Base

  # Named Scopes
  scope :with_subject_status, lambda { |arg| includes(:subject).where(subjects: { status: arg, deleted: false })}

  # Model Validation
  validates_presence_of :subject_id, :schedule_id

  # Model Relationships
  belongs_to :subject
  belongs_to :schedule
  has_many :sheets, -> { where deleted: false }

  def destroy
    self.sheets.each{ |s| s.update( event_id: nil, subject_schedule_id: nil, subject_event_id: nil ) }
    super
  end

  def name
    self.schedule.name
  end

  def offset_date(interval, units)
    return nil unless self.initial_due_date
    interval = interval.to_i
    case units when 'business days'
      multiplier = interval < 0 ? -1 : 1
      interval_weeks = (interval.abs / 5) * multiplier
      interval_days = (interval.abs % 5) * multiplier
      offset = interval_weeks.weeks + interval_days.days
      initial_date = self.initial_due_date
      if interval < 0
        initial_date -= 1.days if initial_date.saturday?
        initial_date -= 2.days if initial_date.sunday?
      else
        initial_date += 2.days if initial_date.saturday?
        initial_date += 1.days if initial_date.sunday?
      end
    else
      offset = interval.send(units)
      initial_date = self.initial_due_date
    end
    new_date = initial_date + offset
    new_date += 2.days if new_date.saturday?
    new_date += 1.days if new_date.sunday?
    new_date
  end

  def panel_hash(event_id, design_id)
    hash = [
      { order: 0, name: 'Missed',     css_class: 'danger' },
      { order: 1, name: 'Unentered', css_class: 'default' },
      { order: 2, name: 'Entered',    css_class: 'info' },
      { order: 3, name: 'Completed',  css_class: 'primary' },
      { order: 4, name: 'Verified',   css_class: 'success' },
      { order: 5, name: 'Ignored',    css_class: 'warning' }
    ]
    name = ( sheet(event_id, design_id) ? 'Entered' : 'Unentered' )
    hash.select{|i| i[:name] == name}.first
  end

  def sheet(event_id, design_id)
    sheets.where( event_id: event_id, design_id: design_id ).first
  end

end
