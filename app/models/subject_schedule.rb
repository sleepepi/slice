class SubjectSchedule < ActiveRecord::Base

  # Model Validation
  validates_presence_of :subject_id, :schedule_id

  # Model Relationships
  belongs_to :subject
  belongs_to :schedule

  def name
    self.schedule ? self.schedule.name : ''
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

  def panel_hash
    hash = [
      { name: 'Incomplete', css_class: 'default' },
      { name: 'Verified',   css_class: 'success' },
      { name: 'Completed',  css_class: 'primary' },
      { name: 'Entered',    css_class: 'info' },
      { name: 'Missed',     css_class: 'danger' },
      { name: 'Ignored',    css_class: 'warning' }
    ]
    hash[rand(hash.size)]
  end

end
