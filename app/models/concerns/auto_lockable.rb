# frozen_string_literal: true

# Allows models to be auto-locked after a specified amount of time
module AutoLockable
  extend ActiveSupport::Concern

  def auto_locked?
    return false if design.ignore_auto_lock?
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

  def reset_auto_lock!(current_user, request)
    requests_granted = recent_unlock_requests
    SheetTransaction.save_sheet!(
      self, {
        unlocked_at: Time.zone.now,
        last_user_id: current_user.id,
        last_edited_at: Time.zone.now
      }, {}, current_user, request.remote_ip, 'sheet_update',
      skip_validation: true
    )
    Notification.where(sheet_unlock_request: sheet_unlock_requests).update_all read: true
    notify_user_of_sheet_unlock_in_background!(requests_granted, current_user)
  end

  def recent_unlock_requests
    sheet_unlock_requests.where('created_at > ?', base_lock_time)
  end

  def recent_unlock_requested?(current_user)
    recent_unlock_requests.where(user_id: current_user.id).count > 0
  end

  def notify_user_of_sheet_unlock_in_background!(requests_granted, project_editor)
    fork_process(:notify_user_of_sheet_unlock, requests_granted, project_editor)
  end

  def notify_user_of_sheet_unlock(requests_granted, project_editor)
    return unless EMAILS_ENABLED
    requests_granted.each do |sheet_unlock_request|
      UserMailer.sheet_unlocked(sheet_unlock_request, project_editor).deliver_now
    end
  end
end
