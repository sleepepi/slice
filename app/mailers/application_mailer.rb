# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "#{ENV['website_name']} <#{ActionMailer::Base.smtp_settings[:email]}>"
  add_template_helper(ApplicationHelper)
  layout 'mailer'

  protected

  def setup_email
    # attachments.inline['slice-logo.png'] = File.read('app/assets/images/try-slice-logo-no-text.png') rescue nil
  end
end
