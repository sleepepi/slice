# frozen_string_literal: true

desc "Launched by crontab -e, send a daily digest of recent activities."
task daily_digest: :environment do
  unless ENV["JOB_SERVER"] == "true"
    puts "SKIP: Not running on job server."
    next
  end

  # At 1am every week day, in production mode, for users who have "daily digest" email notification selected
  return unless EMAILS_ENABLED && Time.zone.today.on_weekday?
  User.current.where(emails_enabled: true).find_each do |user|
    if user.digest_sheets_created.size + user.digest_comments.size > 0
      UserMailer.daily_digest(user).deliver_now
    end
  end
end
