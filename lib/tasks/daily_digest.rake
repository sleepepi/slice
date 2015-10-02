desc 'Launched by crontab -e, send a daily digest of recent activities.'
task daily_digest: :environment do
  # At 1am every week day, in production mode, for users who have "daily digest" email notification selected
  return unless ENV['emails_enabled'] == 'true' && (1..5).include?(Date.today.wday)
  User.current.each do |user|
    if user.digest_sheets_created.size + user.digest_comments.size > 0
      UserMailer.daily_digest(user).deliver_later if user.email_on?(:daily_digest)
    end
  end
end
