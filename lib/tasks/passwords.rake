# frozen_string_literal: true

namespace :passwords do
  desc "Launched by crontab -e, send a password expire email to users."
  task expire: :environment do
    unless ENV["JOB_SERVER"] == "true"
      puts "SKIP: Not running on job server."
      next
    end

    # At 1am every week day, in production mode, for users who have "daily digest" email notification selected
    return unless EMAILS_ENABLED
    User.current.find_each do |user|
      if user.password_expires_soon?
        UserMailer.password_expires_soon(user).deliver_now
      elsif user.password_expires_today?
        user.expire_password!
      end
    end
  end
end
