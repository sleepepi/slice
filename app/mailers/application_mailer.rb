# frozen_string_literal: true

# Generic mailer class defines layout and from email address
class ApplicationMailer < ActionMailer::Base
  default from: "#{ENV['website_name']} <#{ActionMailer::Base.smtp_settings[:email]}>"
  add_template_helper(ApplicationHelper)
  add_template_helper(EmailHelper)
  layout 'mailer'

  protected

  def setup_email
    attachments.inline['slice-logo.png'] = File.read('app/assets/images/try-slice-logo-no-text.png')
  rescue
    nil
  end
end
