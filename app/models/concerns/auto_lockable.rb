# frozen_string_literal: true

# Allows models to be auto-locked after a specified amount of time
module AutoLockable
  extend ActiveSupport::Concern

  def auto_locked?
    return false unless auto_lock_at
    auto_lock_at < Time.zone.now
  end

  def auto_lock_at
    case project.auto_lock_sheets
    when 'after24hours'
      base_lock_time + 24.hours
    when 'after1week'
      base_lock_time + 1.week
    when 'after1month'
      base_lock_time + 1.month
    end
  end

  # This determines when the sheet unlock time was renewed, or when the sheet
  # was created. This is then added to the project setting that determines how
  # long a sheet can stay unlocked to determine the time of auto-lock.
  def base_lock_time
    unlocked_at || created_at
  end

  def reset_auto_lock!
    update unlocked_at: Time.zone.now
    # TODO: Create notification to user who made the unlock request.
  end
end
